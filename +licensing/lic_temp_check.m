function [temp_lic, out] = lic_temp_check(expdate)
serverlist = {'time.nist.gov'; 'time-a-g.nist.gov'; 'time-b-g.nist.gov'; 'time-c-g.nist.gov'; 'time-d-g.nist.gov';
    'time-e-g.nist.gov'; 'time-a-wwv.nist.gov'; 'time-b-wwv.nist.gov'; 'time-c-wwv.nist.gov'; 'time-d-wwv.nist.gov';
    'time-d-wwv.nist.gov'; 'time-e-wwv.nist.gov'; 'time-a-b.nist.gov'; 'time-b-b.nist.gov'; 'time-c-b.nist.gov';
    'time-d-b.nist.gov'; 'time-d-b.nist.gov'; 'time-e-b.nist.gov'; 'utcnist.colorado.edu'; 'utcnist2.colorado.edu'};

    for k = 1:length(serverlist)
        try
            if k>1
                pause(3.75);
            end
            Nist_Time = tcpclient(serverlist{k},13);
            pause(0.5);
            if exist('Nist_Time','var') && Nist_Time.BytesAvailable>0
                break;
            end
        end
    end
    
    tcpdata = read(Nist_Time);
    str = char(tcpdata);
    str = str(8:15);
    outdate = datenum(str,'yy-mm-dd');
    
    exp_date_num = datenum(expdate,'dd/mm/yyyy');
    temp_lic = outdate<exp_date_num;
    out = ['Your license will expire on: ' datestr(exp_date_num,'dd-mmm-yyyy')];
    
    clear str tcpdata Nist_Time k serverlist exp_date_num outdate;
end