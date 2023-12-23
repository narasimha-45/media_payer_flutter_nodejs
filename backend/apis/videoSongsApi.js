const exp = require('express');
const videoApp = exp.Router()
const expressAsyncHandler = require("express-async-handler")

videoApp.use(exp.json())


videoApp.get('/getAllSongs',expressAsyncHandler(async(request,response)=>{
    const videoCollectionObj = request.app.get("videoCollection")
    let allVideos = await videoCollectionObj.find().toArray();
    var songsList =[]
    for (let i=0;i<allVideos.length;i++){
        songsList.push(allVideos[i]['songName'])
    }
    response.send(songsList)
}))

videoApp.get('/getSongUrl/:id',expressAsyncHandler(async(request,response)=>{
    const videoCollectionObj = request.app.get("videoCollection")
    const songDetails = await videoCollectionObj.findOne({songName:request.params.id})
    response.send(songDetails.url)
}))









module.exports = videoApp;