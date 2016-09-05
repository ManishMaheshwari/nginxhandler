
###you can uncomment next two lines for easy debug
###Warning: if master_process is off, there will be only one nginx worker running. Only use it for debug propose.

daemon  off;

#master_process  off;

#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;
    
    jvm_path "/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home/bin/java";

    
    ### Set my app jars and resources, it must include nginx-clojure runtime jar,e.g. nginx-clojure-0.4.4.jar and 
    ### for clojure user clojure runtime jar is also needed.
    ### See http://nginx-clojure.github.io/directives.html#jvm_classpath
    jvm_classpath "jars/*";
    
    ###jvm heap memory
    #jvm_options "-Xms1024m";
    #jvm_options "-Xmx1024m";
    
    #for enable java remote debug uncomment next two lines
    #jvm_options "-Xdebug";
    #jvm_options "-Xrunjdwp:server=y,transport=dt_socket,address=840#{pno},suspend=n";

    ###threads number for request handler thread pool on jvm, default is 0. 
    ###check more details from 
    #jvm_workers 8;
    
       ## share state/rules among nginx worker processes
    shared_map routeRules tinymap?space=32k&entries=256;

    upstream apache {
        server 127.0.0.1:9000;
    }

    upstream staging {
        server 127.0.0.1:10000;
    }

    upstream development {
        server 127.0.0.1:11000;
    }

# map to different upstream backends based on header
map $http_x_server_select $pool {
     default "apache";
     staging "staging";
     dev "development";
}

    server {
        listen       8080;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }
        
        
        

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

       location /clojure {
          handler_type 'clojure';
          handler_code ' 
						(fn[req]
						  {
						    :status 200,
						    :headers {"content-type" "text/plain"},
						    :body  "Hello Clojure & Nginx!" 
						    })
          ';
       }
       
       location /groovy {
           handler_type 'groovy';
           handler_code ' 
                import nginx.clojure.java.NginxJavaRingHandler;
                import java.util.Map;
                public class HelloGroovy implements NginxJavaRingHandler {
                   public Object[] invoke(Map<String, Object> request){
                      return [200, //http status 200
                              ["Content-Type":"text/html"], //headers map
                              "Hello, Groovy & Nginx!"]; 
                   }
                }
           ';
        }
      
     
      
      location /java {
      	content_handler_type 'java';
      	content_handler_name 'com.manish.HelloService';
      }
   
   

    ## $backend will be changed by rewrite handler Router
	  set $backend "";  
	  
   location /router {
  		rewrite_handler_type 'java';
  		rewrite_handler_name 'com.manish.Router';
 		proxy_pass http://$backend;
	}
	
	 location /boss {
#            proxy_pass http://localhost:9000;

	 	  proxy_pass http://$pool;
#             proxy_set_header Host $host;
#             proxy_set_header X-Real-IP $remote_addr;
 
 #standard proxy settings
          proxy_set_header X-Real-IP $remote_addr;
          proxy_redirect off;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $http_host;
          proxy_redirect off;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-NginX-Proxy true;
          proxy_connect_timeout 600;
          proxy_send_timeout 600;
          proxy_read_timeout 600;
          send_timeout 600;        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


       
    }


