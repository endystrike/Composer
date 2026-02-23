function [pub_ip] = f_get_pub_ip()

ipapilist = {'https://api.ipify.org', 'http://ipinfo.io/ip', 'http://ifconfig.me/ip', 'http://icanhazip.com', 'http://ident.me', 'http://smart-ip.net/myip'};
for X=1:length(ipapilist)
    try %#ok<TRYNC> 
        pub_ip = strrep(deblank(webread(ipapilist{X}, weboptions('Timeout',10))),' ','');
        if numel(strfind(pub_ip,'.'))==3 && strlength(pub_ip)>=7 && strlength(pub_ip)<=15
            break;
        end
    end
end

if ~exist('pub_ip','var')
    pub_ip = 'n/a';
end