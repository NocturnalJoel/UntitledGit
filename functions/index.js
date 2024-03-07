const functions = require('firebase-functions');
const stripe = require('stripe')(functions.config().stripe.secret);
const admin = require('firebase-admin');

admin.initializeApp();

exports.createStripeAccount = functions.https.onCall(async (data, context) => {
    // Ensure the user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
    }

    try {
        const account = await stripe.accounts.create({
            type: 'express',
            country: 'CA', // Set the country as per your requirement
            capabilities: {
                card_payments: { requested: true },
                transfers: { requested: true },
            },
        });

        return { accountId: account.id };
    } catch (error) {
        console.error('Error creating Stripe account:', error);
        throw new functions.https.HttpsError('internal', 'Unable to create Stripe account.');
    }
});

exports.fetchStripeAccountInfo = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
    }

    const accountId = data.accountId; // Expecting 'accountId' parameter

    try {
        const account = await stripe.accounts.retrieve(accountId);
        const accountInfo = {
            email: account.email,
            chargesEnabled: account.charges_enabled,
            detailsSubmitted: account.details_submitted,
            payoutsEnabled: account.payouts_enabled,
            country: account.country
            // Add more fields as needed
        };

        await admin.firestore().collection("Users").doc(context.auth.uid).update({
            stripeAccountId: accountInfo // Storing Stripe account info
        });

        return { message: "Stripe account info updated successfully in Firestore." };
    } catch (error) {
        console.error('Error fetching Stripe account info:', error);
        throw new functions.https.HttpsError('internal', 'Unable to fetch Stripe account info.');
    }
});

exports.generateOnboardingLink = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'You must be authenticated to call this function.');
    }

    const accountId = data.accountId; // The Stripe account ID created earlier
    try {
        const accountLink = await stripe.accountLinks.create({
            account: accountId,
            refresh_url: 'https://nocturnaljoel.github.io/Untitled/?type=refresh', // Custom scheme URL for refresh
            return_url: 'https://nocturnaljoel.github.io/Untitled/?type=return',  // Custom scheme URL for return
            type: 'account_onboarding',
        });

        return { url: accountLink.url };
    } catch (error) {
        console.error('Error creating Stripe account link:', error);
        throw new functions.https.HttpsError('internal', 'Unable to create Stripe account link.');
    }
});

exports.createEventProducts = functions.https.onRequest(async (request, response) => {
    // Implement appropriate authentication and error handling here

    try {
        const eventData = request.body;
        const { stripeAccountId, nameOfEvent, costOfEntry, coinPrice, maxAttendance, eventId } = eventData;

        // Create Ticket Product
        const ticketProduct = await stripe.products.create({
            name: `${nameOfEvent} Ticket`,
            description: `Ticket for ${nameOfEvent}`,
        }, { stripeAccount: stripeAccountId });

        // Create Price for Ticket Product
        const ticketPrice = await stripe.prices.create({
            product: ticketProduct.id,
            unit_amount: costOfEntry * 100, // Convert to cents
            currency: 'cad',
        }, { stripeAccount: stripeAccountId });

        // Create Coin Product
        const coinProduct = await stripe.products.create({
            name: `${nameOfEvent} Coin`,
            description: `Coin for ${nameOfEvent}`,
        }, { stripeAccount: stripeAccountId });

        // Create Price for Coin Product
        const coinPriceObj = await stripe.prices.create({
            product: coinProduct.id,
            unit_amount: coinPrice * 100, // Convert to cents
            currency: 'cad',
        }, { stripeAccount: stripeAccountId });

        // Store product IDs in Firestore
        const eventRef = admin.firestore().collection('Events').doc(eventId);
        await eventRef.update({
            ticketProductId: ticketProduct.id,
            ticketPriceId: ticketPrice.id,
            coinProductId: coinProduct.id,
            coinPriceId: coinPriceObj.id,
        });

        response.status(200).send("Event products created successfully");
    } catch (error) {
        console.error("Error creating event products: ", error);
        response.status(500).send("Error creating event products");
    }
});

exports.createCheckoutSession = functions.https.onCall(async (data, context) => {
    // Ensure user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
    }

    // Extract event and user data
    const { event, user } = data;

    try {
        // Create a Stripe checkout session
        const session = await stripe.checkout.sessions.create({
            payment_method_types: ['card'],
            line_items: [{
                // Use an existing product
                price_data: {
                    currency: 'cad',
                    unit_amount: event.costOfEntry * 100, // Assuming costOfEntry is in CAD dollars
                    product: event.ticketProductId, // Reference the existing product ID
                },
                quantity: 1,
            }],
            mode: 'payment',
            success_url: 'https://nocturnaljoel.github.io/Untitled/?type=success',
            cancel_url: 'https://nocturnaljoel.github.io/Untitled/?type=cancel',
            metadata: {
                userId: user.id,
                eventId: event.eventId
            },
         }, {
            stripeAccount: event.stripeAccountId,


        });

        return { url: session.url };
    } catch (error) {
        console.error('Stripe Checkout Session creation failed', error);
        throw new functions.https.HttpsError('internal', 'Unable to create Stripe Checkout session');
    }
});

exports.stripeWebhook = functions.https.onRequest(async (request, response) => {
    const sig = request.headers['stripe-signature'];

    let event;

    try {
        event = stripe.webhooks.constructEvent(
            request.rawBody, 
            sig, 
            functions.config().stripe.webhooksecret
        );
    } catch (err) {
        console.error(`Webhook signature verification failed.`, err.message);
        return response.sendStatus(400);
    }

    // Handle the checkout.session.completed event
    if (event.type === 'checkout.session.completed') {
        const session = event.data.object;

        // Retrieve user and event IDs from session metadata
        const userId = session.metadata.userId;
        const eventId = session.metadata.eventId;
        const numberOfCoins = session.metadata.numberOfCoins || 0;


        try {
            await admin.firestore().runTransaction(async (transaction) => {
                const eventRef = admin.firestore().collection('events').doc(eventId);
                const userRef = admin.firestore().collection('users').doc(userId);

                const eventDoc = await transaction.get(eventRef);
                const userDoc = await transaction.get(userRef);

                if (!eventDoc.exists || !userDoc.exists) {
                    throw new Error("Document does not exist!");
                }

                // Add user's name and ID to the event's guestNames
                const guestNames = eventDoc.data().guestNames || [];
                guestNames.push({ name: userDoc.data().name, id: userId, coins: numberOfCoins });
                transaction.update(eventRef, { guestNames });

                // Add event's name and ID to the user's ticketsIPaidFor
                const ticketsIPaidFor = userDoc.data().ticketsIPaidFor || [];
                let found = false;
                
                ticketsIPaidFor.forEach(ticket => {
                    if (ticket.eventId === eventId) {
                        ticket.numberOfCoins = (ticket.numberOfCoins || 0) + numberOfCoins;
                        found = true;
                    }
                });

                if (!found) {
                    ticketsIPaidFor.push({
                        eventId: eventId,
                        eventName: eventDoc.data().nameOfEvent,
                        numberOfCoins: numberOfCoins
                    });
                }
                transaction.update(userRef, { ticketsIPaidFor });

            });

            response.status(200).send("Firestore updated successfully");
        } catch (error) {
            console.error("Firestore transaction failed:", error);
            response.status(500).send("Firestore transaction failed");
        }
    } else {
        response.status(200).send("Event type is not checkout.session.completed");
    }
});
exports.createCheckoutSessionCoin = functions.https.onCall(async (data, context) => {
    // Ensure user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
    }   
        
    // Extract event and user data
    const { event, user } = data;
        
    try {
        // Create a Stripe checkout session
        const session = await stripe.checkout.sessions.create({
            payment_method_types: ['card'],
            line_items: [{
                // Use an existing product
                price_data: {
                    currency: 'cad',
                    unit_amount: event.total * 100, // Assuming costOfEntry is in CAD dollars
                    product: event.coinProductId, // Reference the existing product ID
                },
                quantity: 1,
            }],
            mode: 'payment',
            success_url: 'https://nocturnaljoel.github.io/Untitled/?type=success',
            cancel_url: 'https://nocturnaljoel.github.io/Untitled/?type=cancel',
            metadata: {
                userId: user.id,
                eventId: event.eventId,
                numberOfCoins: event.numberOfCoins
            },
         }, {
            stripeAccount: event.stripeAccountId,
            
        
        });
        
        return { url: session.url };
    } catch (error) {
        console.error('Stripe Checkout Session creation failed', error);   
        throw new functions.https.HttpsError('internal', 'Unable to create Stripe Checkout session');
    }
});             
     
