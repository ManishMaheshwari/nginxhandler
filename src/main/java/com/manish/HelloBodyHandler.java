package com.manish;

import java.util.Map;

import nginx.clojure.java.ArrayMap;
import nginx.clojure.java.NginxJavaRingHandler;
import static nginx.clojure.MiniConstants.*;

public  class HelloBodyHandler implements NginxJavaRingHandler {

    @Override
    public Object[] invoke(Map<String, Object> request) {
        return new Object[] {
                NGX_HTTP_OK, //http status 200
                ArrayMap.create(CONTENT_TYPE, "text/plain"), //headers map
                "Hello, Java & Nginx!"  //Body
                };
    }
}