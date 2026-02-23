function [wb] = f_waitbar_text_left(wb)
    wax = findobj(wb,'type','axes');
    tax = get(wax,'title');
    set(tax,'HorizontalAlignment','left','fontsize',8);
    a = get(tax,'Position');
    a(1) = 0;
    set(tax,'Position',a);
end