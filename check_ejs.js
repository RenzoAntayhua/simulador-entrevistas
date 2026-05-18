const ejs = require('ejs');
const fs = require('fs');

try {
    ejs.compile(fs.readFileSync('src/views/retos/resolver.ejs', 'utf-8'));
    console.log('resolver.ejs is OK');
} catch(e) {
    console.error('ERROR resolver.ejs:', e);
}

try {
    ejs.compile(fs.readFileSync('src/views/batalla/sala.ejs', 'utf-8'));
    console.log('sala.ejs is OK');
} catch(e) {
    console.error('ERROR sala.ejs:', e);
}
