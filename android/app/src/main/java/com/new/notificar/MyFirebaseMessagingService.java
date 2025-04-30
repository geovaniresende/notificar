package com.example.notificar;

import android.util.Log;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class MyFirebaseMessagingService extends FirebaseMessagingService {

    private static final String TAG = "MyFirebaseMsgService";

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Log.d(TAG, "Mensagem recebida: " + remoteMessage.getNotification().getBody());
    }

    @Override
    public void onNewToken(String token) {
        Log.d(TAG, "Novo token: " + token);
    }
}
