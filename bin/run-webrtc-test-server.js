// This is a test server run for testing the webrtc datastore implementation
const fs = require('fs')
const path = require('path')
const http = require('http')
const port = 3000

const html = `
<body>
  <script src="/webrtc.js"></script>
</body>
`

const server = http.createServer((req, res) => {
  if (req.url === '/') {
    res.writeHead(200, {
      'Cache-Control': 'no-cache'
    })
    res.end(html)
  } else if (req.url === '/webrtc.js') {
    res.writeHead(200, {
      'Cache-Control': 'no-cache'
    })
    fs.createReadStream(path.join(__dirname, '../src/js/db/webrtc.js')).pipe(res)
  }
})

server.listen(port, () => {
  console.log(`Listening on ${port}.`)
})
