package com.manish;

import java.io.IOException;
import java.util.Map;

import nginx.clojure.java.NginxJavaRequest;
import nginx.clojure.java.NginxJavaRingHandler;
import nginx.clojure.util.NginxSharedHashMap;

/**
 * TBD: Rules must be taken from a Routing DSL file. 
 * @author mmaheshwari
 *
 */

public class Router implements NginxJavaRingHandler {

	private static final String X_SERVER_CHOOSE = "X-Server-Choose";
	public static final String HEADER_KEY = "headers";
	
	public static NginxSharedHashMap<String, String> rules = new NginxSharedHashMap("routeRules");

	static {
		rules.put("1", "apache");
		rules.put("2", "staging");
		rules.put("3", "development");
		rules.put("default", "apache");
	}

	@Override
	public Object[] invoke(Map<String, Object> request) throws IOException {
		
		for (String key : request.keySet()) {
			System.out.println("Key : " + key + "\t Value: " + request.get(key));
			if (key.equals(HEADER_KEY)) {
				Map<String, Object> headers = (Map<String, Object>) request.get(key);
				for (String h : headers.keySet()) {
					System.out.println("\t\t " + h + ":" + headers.get(h));
				}
			}
		}
		Map<String, Object> headers = (Map<String, Object>) request.get(HEADER_KEY);
		String choice = (String) headers.get(X_SERVER_CHOOSE);
		if (choice != null) {
			String backend = rules.get(choice);
			backend = backend == null ? rules.get("default") : backend;
			((NginxJavaRequest) request).setVariable("backend", backend);
		}else{
			((NginxJavaRequest) request).setVariable("backend", rules.get("default"));
		}
		return nginx.clojure.java.Constants.PHASE_DONE;
	}
}