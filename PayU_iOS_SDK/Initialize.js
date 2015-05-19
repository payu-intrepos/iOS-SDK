{
detectBank: '(function(){
    if(/hdfc/i.test(location.host)) {
        PayU.bankFound("hdfc")
    } else if(/citi/i.test(location.host)) {
        PayU.bankFound("citi");
    } else if(/secure4\.arcot\.com/i.test(location.host)) {
        PayU.bankFound("sbi");
    } else if(/cardsecurity\.standardchartered\.com/i.test(location.host)) {
        PayU.bankFound("sc");
    } else if(/hsbc\.co\.in/i.test(location.host)) {
        PayU.bankFound("hsbc");
    } else if(/secureonline\.idbibank\.com/i.test(location.host)) {
        PayU.bankFound("idbi");
    } else if(/acs\.icicibank\.com/i.test(location.host)) {
        PayU.bankFound("icici");
    } else if(/cardsecurity\.enstage\.com/i.test(location.host)) {
        PayU.bankFound("kotak");
    } else if(/www\.safekey\.americanexpress\.com/.test(location.host)) {
        PayU.bankFound("amex");
    } else if(/www\.onlinesbi\.com/.test(location.host)){
        PayU.bankFound("sbinet");
    } else if(/www\.axisbank\.co\.in/i.test(location.host)) {
        PayU.bankFound("axis_net");
    }
})();',
detectOtp: 'pin|otp|password|netsecure',
findOtp: '((^|[^0-9])[0-9]{6,8}([^0-9]|$))'
}