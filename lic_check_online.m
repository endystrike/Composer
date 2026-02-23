function [online_check] = lic_check_online(iid)
    baseurl = 'https://licensing.ungeracademy.com/composer/lic/';    %url root licenze attivate
    iidurl = strrep(iid,'/','');
    iidurl = strrep(iidurl,'+','');
    iidurl = strrep(iidurl,'\','');
    iidurl = strrep(iidurl,'-','');
    iidurl = strrep(iidurl,'@','');
    url = char(strcat(baseurl,iidurl));

    %verifica se esiste url
    [~,online_check] = urlread(url); %#ok<*URLRD>
    clear iidurl baseurl url;
end