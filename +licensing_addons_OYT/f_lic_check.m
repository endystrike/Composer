function [license_ok] = f_lic_check

defLic = licensing_addons_OYT.f_lic_checkDefault;
switch defLic
    case 0
        license_ok = licensing_addons_OYT.auxilium.f_check_license_auxilium || licensing_addons_OYT.f_license_ip_check || licensing_addons_OYT.f_lifetime_check;
    case 1
        license_ok = licensing_addons_OYT.auxilium.f_check_license_auxilium;
    case 2
        license_ok = licensing_addons_OYT.f_license_ip_check;
    case 3
        license_ok = licensing_addons_OYT.f_lifetime_check;
end