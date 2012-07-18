function Send() {
  $.get('/app/Bluetooth/send_message', { message: document.getElementById("message").value});
  document.getElementById("message").value = "";
  return false;
}

function Connect() {
  $.get('/app/Bluetooth/connect_to_device', { server_name: document.getElementById("server_name").value});
  return false;
}

function Server_Wait() {
  $.get('/app/Bluetooth/server_wait');
  return false;
}

function Disconnect() {
  $.get('/app/Bluetooth/disconnect');
  return false;
}

function Write(msg) {
  document.getElementById("chat").value = msg + document.getElementById("chat").value;
  return false;
}


