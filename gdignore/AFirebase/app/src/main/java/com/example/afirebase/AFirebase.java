package com.example.afirebase;


import android.content.Intent;
import android.os.Bundle;
import android.util.ArraySet;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.analytics.FirebaseAnalytics;

import org.godotengine.godot.Dictionary;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class AFirebase extends GodotPlugin {
    public AFirebase(Godot godot) {
        super(godot);
    }

    private FirebaseAnalytics mFirebaseAnalytics;



    @NonNull
    @Override
    public String getPluginName() {
        return "AFirebase";
    }


    @NonNull
    @Override
    public List<String> getPluginMethods() {
        // Регистрация методов и сигналов
        return Arrays.asList(
//                Analytics
                "getInstance", "getInstanceSignal", "logEvent", "resetAnalyticsData",
                "setAnalyticsCollectionEnabled", "setSessionTimeoutDuration", "setUserId",
                "setUserProperty", "setDefaultEventParameters", "getAppInstanceId", "getAppInstanceIdSignal",
                "setConsent", "getSessionId", "getSessionIdSignal"
        );
    }

    @NonNull
    @Override
    public Set<SignalInfo> getPluginSignals() {
        // Регистрация сигналов
        Set<SignalInfo> signals = new ArraySet<>();
        signals.add(new SignalInfo("getInstanceSignal"));
        signals.add(new SignalInfo("getAppInstanceIdSignal", String.class));
        signals.add(new SignalInfo("getSessionIdSignal", Integer.class));

        return signals;
    }

    public void getInstance() {
        mFirebaseAnalytics = FirebaseAnalytics.getInstance(getActivity().getApplicationContext());

        getInstanceSignalC();
    }

//    / ///
//    ANALYTICS
//    / ///

//    Извлекает идентификатор экземпляра приложения из службы или null,
//    если FirebaseAnalytics.ConsentType.ANALYTICS_STORAGE был установлен
//    в FirebaseAnalytics.ConsentStatus.DENIED.
    public void getAppInstanceId() {
        mFirebaseAnalytics.getAppInstanceId().addOnCompleteListener(new OnCompleteListener<String>() {
            @Override
            public void onComplete(@NonNull Task<String> task) {
                if (task.isSuccessful()) {
                    String user_pseudo_id = task.getResult();
                    if (user_pseudo_id == null) {
                        user_pseudo_id = "ANALYTICS_STORAGE DENIED";
                    }
                    getAppInstanceIdSignal(user_pseudo_id);
                }
            }
        });
    }

//    Извлекает идентификатор сеанса у клиента. Возвращает null, если
//    FirebaseAnalytics.ConsentType.ANALYTICS_STORAGE был установлен
//    в FirebaseAnalytics.ConsentStatus.DENIED или срок действия сеанса истек.
    public void getSessionId() {
        mFirebaseAnalytics.getSessionId().addOnCompleteListener(new OnCompleteListener<Long>() {
            @Override
            public void onComplete(@NonNull Task<Long> task) {
                if (task.isSuccessful()) {
                    Long user_pseudo_id = task.getResult();
                    if (user_pseudo_id == null) {
                        user_pseudo_id = (long) -1;
                    }
                    Integer result = new Integer(Math.toIntExact(user_pseudo_id));
                    getSessionIdSignalC(result);
                }
            }
        });

    }

//    Регистрирует события приложения
//    Имя, параметры для события (godot Dictionary)
//    ("testEvent", {"testParam": {"value": "stringParam", "type": "string"}, "testParam2": {...}})
    public void logEvent(String event, Dictionary params) {
        Bundle bundle = new Bundle();
        String[] paramsKeys = params.get_keys();
        Object[] paramsValues = params.get_values(); // value = Dictionary
        for (int i = 0; i < paramsKeys.length; i++) {
            Dictionary param = (Dictionary) paramsValues[i];
            Object[] paramValues = param.get_values();
            switch (paramValues[0].toString()) {
                case("string"):
                    bundle.putString(paramsKeys[i], paramValues[1].toString());
                    break;
                case("long"):
                    bundle.putLong(paramsKeys[i], new Long((int)paramValues[1]));
                    break;
                case("double"):
                    bundle.putDouble(paramsKeys[i], (double)paramValues[1]);
                    break;
            }

        }
        mFirebaseAnalytics.logEvent(event, bundle);
    }

//    Удаляет с устройства все аналитические данные для этого приложения и сбрасывает идентификатор экземпляра приложения.
    public void resetAnalyticsData() {
        mFirebaseAnalytics.resetAnalyticsData();
    }

//    Определяет, включен ли сбор аналитики для этого приложения на данном устройстве.
//    Этот параметр сохраняется во всех сеансах приложения. По умолчанию он включен.
    public void setAnalyticsCollectionEnabled(boolean enabled) {
        mFirebaseAnalytics.setAnalyticsCollectionEnabled(enabled);
    }

//    Устанавливает применимое состояние согласия конечного пользователя
//    (например, для идентификаторов устройств) для этого приложения на данном устройстве.
//    Используйте карту согласия, чтобы указать индивидуальные значения типа согласия.
//    Настройки сохраняются во всех сеансах приложения. По умолчанию для типов согласия установлено значение "предоставлено".
    public void setConsent(boolean analytics_storage, boolean adStorage) {
        Map<FirebaseAnalytics.ConsentType, FirebaseAnalytics.ConsentStatus> consent = new HashMap<>();

        if (analytics_storage) { consent.put(FirebaseAnalytics.ConsentType.ANALYTICS_STORAGE, FirebaseAnalytics.ConsentStatus.GRANTED); }
        else { consent.put(FirebaseAnalytics.ConsentType.ANALYTICS_STORAGE, FirebaseAnalytics.ConsentStatus.DENIED); }

        if (adStorage) { consent.put(FirebaseAnalytics.ConsentType.AD_STORAGE, FirebaseAnalytics.ConsentStatus.GRANTED); }
        else { consent.put(FirebaseAnalytics.ConsentType.AD_STORAGE, FirebaseAnalytics.ConsentStatus.DENIED); }
        mFirebaseAnalytics.setConsent(consent);
    }

//    Добавляет параметры, которые будут устанавливаться для каждого события, регистрируемого из SDK,
//    включая автоматические. Значения, переданные в пакете параметров, будут добавлены к карте
//    параметров события по умолчанию. Эти параметры сохраняются при запуске приложения.
//    Они имеют более низкий приоритет, чем параметры события, поэтому, если параметр события и параметр,
//    установленный с помощью этого API, имеют одинаковое имя, будет использоваться значение параметра события.
//    Те же ограничения на параметры события применяются и к параметрам события по умолчанию.
    public void setDefaultEventParameters(Dictionary parameters) {
        Bundle params = new Bundle();
        String[] paramsKeys = parameters.get_keys();
        Object[] paramsValues = parameters.get_values(); // value = Dictionary
        for (int i = 0; i < paramsKeys.length; i++) {
            Dictionary param = (Dictionary) paramsValues[i];
            Object[] paramValues = param.get_values();
            switch (paramValues[0].toString()) {
                case("string"):
                    params.putString(paramsKeys[i], paramValues[1].toString());
                    break;
                case("long"):
                    params.putLong(paramsKeys[i], new Long((int)paramValues[1]));
                    break;
                case("double"):
                    params.putDouble(paramsKeys[i], (double)paramValues[1]);
                    break;
            }

        }
        mFirebaseAnalytics.setDefaultEventParameters(params);
    }

//    Задает продолжительность бездействия, которая завершает текущий сеанс.
//    Значение по умолчанию равно 1800000 (30 минут).
    public void setSessionTimeoutDuration(int milliseconds){
        mFirebaseAnalytics.setSessionTimeoutDuration(new Long((int)milliseconds));
    }

//    Задает свойство user ID. Эта функция должна использоваться в соответствии с Политикой конфиденциальности Google.
    public int setUserId(String id) {
        if (id.length() > 256) { return 0; }
        mFirebaseAnalytics.setUserId(id);
        return 1;
    }

//    Устанавливает пользовательскому свойству заданное значение.
//    Поддерживается до 25 имен пользовательских свойств.
//    После установки значения пользовательских свойств сохраняются на протяжении всего жизненного цикла приложения и в разных сеансах.
    public void setUserProperty(String name, String value) {
        mFirebaseAnalytics.setUserProperty(name, value);
    }


    public void getSessionIdSignalC(Integer sessionId) {
        emitSignal("getSessionIdSignal", sessionId);
    }

    public void getAppInstanceIdSignal(String appId) {
        emitSignal("getAppInstanceIdSignal", appId);
    }

    public void getInstanceSignalC() {
        emitSignal("getInstanceSignal");
    }

}
