# nginx-lua
Nginx with LUA support.

## build
```
Docker build -t lua .
```
Nothing interesting

## nginx.conf
Must contain the next...   
```
http{
    include mime.types;
    default_type application/json
    lua_package_path "/opt/lua-resty-core/lib/?.lua;/opt/lua-resty-lrucache/lib/?.lua;/opt/lua-resty-mysql/lib/?.lua;;";
    ...
```
## Run
• Create config or steal default config from /opt/nginx/conf/*  
• Place config in some folder  
  
```
docker run --rm -it -p 80:80 -v /some_folder/:/mnt/config/:r lua /bin/bash
```
  
Anyway, it's not thing-in-itself, it's just template. If you reading this it means you know what to do...  

## Example of usage

### What is it:
1) We have service which listening only 127.0.0.1:1338 (Unavailable from outside)  
2) We want to ban some bad men  
3) Nginx will serach every ip-address and if address in blacklist.txt - drop connection.  
  
!This is a very non-optimal flow. Do not use it if the load is more than 10-20 connections per minute!  
  
### How it is done?
```
    server {
        listen       443 ssl http2;
        listen       [::]:443 ssl http2;
        server_name  mysite.com;
        charset utf-8;

        ssl_certificate      /etc/letsencrypt/live/mysite.com/cert.pem;
        ssl_certificate_key  /etc/letsencrypt/live/mysite.com/privkey.pem;
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
        include /etc/letsencrypt/options-ssl-nginx.conf;
        client_max_body_size 1k;
        client_body_buffer_size 1k;

        error_log logs/fs-1.error.log;

        location / {
            
            limit_except POST {
                deny  all;
            }

           set_by_lua_block $a {
                lines = {}
                flag = 1

                for line in io.lines('/opt/blacklist.txt') do
                        lines[#lines + 1] = line
                end
                for k,v in pairs(lines) do
                        if ngx.var.remote_addr == v then
                                flag = 0
                                break
                        end
                end
                return flag
            }
            if ($a = 0) {
                return 403;
            }

                 scgi_param  SCGI               1;                  
                 scgi_param  HTTPS              $https if_not_empty;
                 scgi_param  REQUEST_METHOD     $request_method;    
                 scgi_param  CONTENT_LENGTH     $content_length;    
                 scgi_param  REMOTE_ADDR        $remote_addr;       
                 scgi_pass   127.0.0.1:1338;                        
                                                                    
```

