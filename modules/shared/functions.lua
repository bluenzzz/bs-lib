Lib.Shared = {}

Lib.Shared.formatCurrency = function(value, currency)
    local currencies <const> = {
        ['BRL'] = 'R$ ',  
        ['USD'] = 'US$ ', 
        ['EUR'] = '€ ',   
        ['GBP'] = '£ ',   
        ['JPY'] = '¥ ',   
        ['CNY'] = '¥ ',   
        ['INR'] = '₹ ',   
        ['RUB'] = '₽ ',   
        ['AUD'] = 'A$ ',  
        ['CAD'] = 'C$ ',  
        ['CHF'] = 'CHF ', 
        ['MXN'] = 'MX$ ', 
        ['ARS'] = 'AR$ ', 
        ['CLP'] = 'CL$ ', 
        ['ZAR'] = 'R ',   
        ['KRW'] = '₩ ',   
        ['IDR'] = 'Rp ',  
        ['TRY'] = '₺ ',   
        ['ILS'] = '₪ ',   
        ['SAR'] = '﷼ ',   
        ['SGD'] = 'S$ ',  
        ['NZD'] = 'NZ$ ', 
        ['HKD'] = 'HK$ ', 
        ['AED'] = 'د.إ ', 
        ['MYR'] = 'RM ',  
        ['THB'] = '฿ ',   
        ['SEK'] = 'kr ',  
        ['NOK'] = 'kr ',  
        ['DKK'] = 'kr ',  
        ['PLN'] = 'zł ',  
        ['CZK'] = 'Kč ',  
        ['HUF'] = 'Ft ',  
        ['VND'] = '₫ '    
    }

    local formatted = string.format('%.2f', value):gsub('%.', ',')
    formatted = formatted:reverse():gsub('(%d%d%d)', '%1.'):reverse()
    formatted = formatted:gsub('^%.', '')
    return (currencies[currency] or 'US$ ')..formatted
end