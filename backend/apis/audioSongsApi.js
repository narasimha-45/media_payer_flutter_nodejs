const exp = require('express');
const audioApp = exp.Router()
const expressAsyncHandler = require("express-async-handler")

audioApp.use(exp.json())


audioApp.get('/getAllSongs', expressAsyncHandler(async (request, response) => {
    const audioCollectionObj = request.app.get("audioCollection")
    const songs = await audioCollectionObj.find({}, { songName: 1}).toArray()
    
    let songsList = [];
    
    for(let i=0;i<songs.length;i++){
        songsList.push(songs[i].songName) 
    }
    
    response.send(songsList);

}))

audioApp.get('/getSongUrl/:id', expressAsyncHandler(async (request, response) => {
    const audioCollectionObj = request.app.get("audioCollection")
    const songDetails = await audioCollectionObj.findOne({ songName: request.params.id });
    response.setHeader('Content-Type', 'audio/mpeg');
    response.setHeader('Content-Disposition', `attachment; filename="${request.params.id}.mp3"`);
    const bufferAudio = songDetails.audio.buffer
    response.send(bufferAudio);
}))




module.exports = audioApp;