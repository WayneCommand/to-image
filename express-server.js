const express = require('express')
const multiparty = require('multiparty');
const cors = require('cors')
const sharp = require('sharp');


const app = express()

app.use(cors({
    origin: '*'
}))

app.post('/api/image/:type', function (req, res) {

    let form = new multiparty.Form();
    let image = {
        filename: 'untitled.',
        size: 0,
        buffer: []
    };


    form.on('close', () => {

        try {
            image_process(form, image, req.params.type, res);
        } catch (e) {
            console.log(e)
        }

    });

    // listen on part event for image file
    form.on('part', part => {
        image_receive(part, image);
    });

    // parse the form
    form.parse(req);
})

app.listen(8081)
console.log('Express started on port 8081');

const image_receive = (part, image) => {
    if (!part.filename) return;
    if (part.name !== 'image') return part.resume();
    image.filename = part.filename;
    part.on('data', (buf) => {
        image.size += buf.length;
        image.buffer.push(buf);
    });
};

const image_process = (form, image, format, res) => {
    console.log('image process start')

    let inputSharp = sharp(Buffer.concat(image.buffer));

    if (format === 'heic'){
        inputSharp = inputSharp.toFormat(format, {
            quality: 80,
            compression: 'hevc'
        });
    }else {
        inputSharp = inputSharp.toFormat(format, {
            quality: 80
        });
    }

    inputSharp.toBuffer((err, data, info) => {

        if (err) {
            console.log(err);
        }

        console.log('image process end')
        switch (format) {
            case 'jpg':
                res.set('Content-Type', 'image/jpg');
                break;
            case 'png':
                res.set('Content-Type', 'image/png');
                break;
            case 'webp':
                res.set('Content-Type', 'image/webp');
                break;
            case 'heic':
                res.set('Content-Type', 'image/heic');
                break;
            case 'heif':
                res.set('Content-Type', 'image/heif');
                break;
            case 'avif':
                res.set('Content-Type', 'image/avif');
                break;
        }
        res.send(data);
    });
};