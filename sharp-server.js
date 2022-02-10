// http.js
// 1. 加载 http 核心模块
const http = require('http')
const sharp = require('sharp');
const { URLSearchParams } = require('url');

const port = 8081;

// 2. 使用 http.createServer() 方法创建一个 Web 服务器
const server = http.createServer()

/**
 * server request 事件处理
 * @param Request 请求对象可以用来获取客户端的一些请求信息，例如请求路径
 * @param Response 响应对象可以用来给客户端发送响应消息
 */
server.on('request', (request, response) => {
    console.log('收到客户端的请求了，请求路径是：' + request.url)

    let body = [];
    // https://stackoverflow.com/questions/4295782/how-to-process-post-data-in-node-js
    request.on('data', chunk => body.push(chunk))
        .on('end',() => {
            let buffer = Buffer.concat(body);

            // let urlSearchParams = new URLSearchParams(buffer.toString());

            console.log(buffer.toString('utf8', 0, 200));

            /*sharp(buffer)
                .webp()
                .toBuffer((err, data, info) => {
                    console.log(err);
                    console.log(info);
                });*/

            response.write('resp over.');
            // 告诉客户端，我的话说完了，你可以呈递给用户了
            response.end();

        })
});

server.listen(port, () => {
    console.log(`服务器启动成功了，可以通过 http://127.0.0.1:${port}/ 来进行访问`);
})