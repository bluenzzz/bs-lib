local CURRENCIES <const> = {
    BRL = "R$ ",
    USD = "US$ ",
    EUR = "€ ",
    GBP = "£ ",
    JPY = "¥ ",
    CNY = "¥ ",
    INR = "₹ ",
    RUB = "₽ ",
    AUD = "A$ ",
    CAD = "C$ ",
    CHF = "CHF ",
    MXN = "MX$ ",
    ARS = "AR$ ",
    CLP = "CL$ ",
    ZAR = "R ",
    KRW = "₩ ",
    IDR = "Rp ",
    TRY = "₺ ",
    ILS = "₪ ",
    SAR = "﷼ ",
    SGD = "S$ ",
    NZD = "NZ$ ",
    HKD = "HK$ ",
    AED = "د.إ ",
    MYR = "RM ",
    THB = "฿ ",
    SEK = "kr ",
    NOK = "kr ",
    DKK = "kr ",
    PLN = "zł ",
    CZK = "Kč ",
    HUF = "Ft ",
    VND = "₫ ",
}

---@param value number
---@param currency? string
local function FormatCurrency(value, currency)
    local symbol = CURRENCIES[currency or "USD"] or CURRENCIES.USD
    local sign = value < 0 and "-" or ""
    local integer, decimal = ("%.2f"):format(math.abs(value)):match("^(%d+)%.(%d+)$")
    local grouped = integer:reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", "")

    return sign .. symbol .. grouped .. "," .. decimal
end

return FormatCurrency
