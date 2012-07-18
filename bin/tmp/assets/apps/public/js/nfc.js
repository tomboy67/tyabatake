function message_byte(log) {
  document.getElementById("message_byte").value = log;
}

function id(log) {
  document.getElementById("id").value = log;
}

function manufacturer(log) {
  document.getElementById("manufacturer").value = log;
}

function system(log) {
  document.getElementById("system").value = log;
}

function tech(log) {
  document.getElementById("tech").value = log;
}
    
function max_size(log) {
  document.getElementById("max_size").value = log;
}

function writable(log) {
  document.getElementById("writable").value = log;
}

function readonly(log) {
  document.getElementById("readonly").value = log;
}

function tnf(log) {
  document.getElementById("tnf").value = log;
}

function rtd(log) {
  document.getElementById("rtd").value = log;
}

function payload(log) {
  document.getElementById("payload").value = log;
}

function type(log) {
  document.getElementById("type").value = log;
}

function clear(){
  	document.getElementById("id").value = "";
	document.getElementById("message_byte").value = "";
	document.getElementById("system").value = "";
	document.getElementById("tech").value = "";
	document.getElementById("writable").value = "";
	document.getElementById("max_size").value = "";
	document.getElementById("type").value = "";
	document.getElementById("payload").value = "";
	document.getElementById("rtd").value = "";
	document.getElementById("tnf").value = "";
	document.getElementById("readonly").value = "";
	document.getElementById("manufacturer").value = "";
}