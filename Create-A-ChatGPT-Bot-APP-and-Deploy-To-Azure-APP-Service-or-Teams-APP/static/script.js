document.addEventListener("DOMContentLoaded", function() {
  const form = document.getElementById("chat-form");
  form.addEventListener("submit", function(event) {
    event.preventDefault(); // prevent the form from reloading the page
    const message = document.getElementById("message").value; // get the user's message
    // send an AJAX request to the Python script
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState == XMLHttpRequest.DONE) {
        // display the GPT response on the page
        document.getElementById("gpt-response").innerHTML = xhr.responseText;
      }
    }
    xhr.open("POST", "/process_gpt", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.send(`message=${encodeURIComponent(message)}`);
  });
});
