/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

admin.initializeApp();

sgMail.setApiKey(functions.config().sendgrid.key);

// Esta función se activa cuando se crea un nuevo documento en la colección 'invitations'
exports.sendInvitationEmail = functions.firestore
  .document('invitations/{invitationId}')
  .onCreate(async (snap, context) => {
    console.log('Función activada - Datos recibidos:', snap.data());
    
    const data = snap.data();
    const email = data.email;
    const code = data.code;
    const businessId = data.businessId;

    console.log('Preparando email para:', email);

    const msg = {
      to: email,
      from: 'francisco.orta@ieee.org',
      subject: 'Invitación para unirte a un negocio',
      text: `Te han invitado a unirte al negocio ${businessId}. Tu código de invitación es: ${code}. Este código expira en 15 minutos.`,
      html: `<p>Te han invitado a unirte al negocio <b>${businessId}</b>.<br>
             Tu código de invitación es: <b>${code}</b>.<br>
             Este código expira en 15 minutos.</p>`,
    };

    try {
      console.log('Intentando enviar email...');
      await sgMail.send(msg);
      console.log('Email enviado exitosamente a:', email);
    } catch (error) {
      console.error('Error detallado:', error.response ? error.response.body : error);
      throw error; // Esto asegura que el error aparezca en los logs
    }
    return null;
  });
