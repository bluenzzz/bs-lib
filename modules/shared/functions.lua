Lib.Functions.formatCurrency = function(value, currency)
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

--==========================================================

local isResourceStartedOrStarting = function(resource)
    local state = GetResourceState(resource)
    return (state == 'started' or state == 'starting')
end

Lib.Functions.getFramework = function()
    local framework = 'standalone'

    local frameworks <const> = {
        ['es_extended'] = 'esx',
        ['vrp'] = 'vrp',
        ['qb-core'] = 'qb',
        ['qbx_core'] = 'qbox'
    }

    for k, v in pairs(frameworks) do
        if isResourceStartedOrStarting(k) then
            framework = v
            break
        end
    end

    return framework
end

Lib.Functions.getInventory = function()
    local inventory = 'standalone'

    local inventorys = {
        'vrp_inventory',
        'ox_inventory',
        'qb-inventory',
        'qs-inventory'
    }

    for i = 1, #inventorys do
        if isResourceStartedOrStarting(inventorys[i]) then
            inventory = inventorys[i]
            break
        end
    end

    return inventory
end