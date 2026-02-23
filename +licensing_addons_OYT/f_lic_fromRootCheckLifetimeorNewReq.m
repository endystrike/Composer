function [lifetime] = f_lic_fromRootCheckLifetimeorNewReq()
    [lifetime,~,~] = licensing_addons_OYT.f_lifetime_check;
    if ~lifetime
%         try
%             webread(['https://licensing.ungeracademy.com/lics_requests/', char(licensing.f_cleanStr4FileName(iid))],weboptions('Timeout',15,'ContentType','text'));
%             status=1;
%         catch
%             status=0;
%         end
% 
%         if status==0
%             try
%                 webread(['https://licensing.ungeracademy.com/lics_reqs_sandbox/',char(licensing.f_cleanStr4FileName(iid))],weboptions('Timeout',15,'ContentType','text'));
%                 status=2;
%             catch
%                 status=0;
%             end
%         end
%         
%         if status==0
            waitfor(licensing_addons_OYT.lic_new_activate);
            [lifetime,~,~] = licensing_addons_OYT.f_lifetime_check;
            if lifetime
                fid = fopen('DefLic.txt','w'); fprintf(fid,'%d',3); fclose(fid);
            end
%         elseif status==1
%             waitfor(licensing.lic_new_alreadyasked);
%         elseif status==2
%             waitfor(msgbox('Your activation is under approval (e.g. you may have exceeded maximum activation attempts) and needs to be approved manually by the staff.'));
%         end
    else
        fid = fopen('DefLic.txt','w'); fprintf(fid,'%d',3); fclose(fid);
    end
end