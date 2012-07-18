function Clear() {
    $.get('/app/Signature/clear');
    return false;
}
function Capture() {
    $.get('/app/Signature/capture');
    return false;
}
function Take_Signature_Inline() {
    $.get('/app/Signature/take_signature_inline');
    return false;
}

