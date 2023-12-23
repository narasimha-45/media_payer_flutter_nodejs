const exp = require('express')
const app = exp()


app.listen(5500,()=>console.log("server started"))

const mongoClient = require('mongodb').MongoClient

mongoClient.connect('mongodb://0.0.0.0:27017')
.then((dbref)=>{
    const dbObj = dbref.db('media_player');
    const usersCollection = dbObj.collection("usersData")
    const audioCollection = dbObj.collection("audioSongs")
    const videoCollection = dbObj.collection("videoSongs")
    app.set("videoCollection",videoCollection)
    app.set("audioCollection",audioCollection)
    app.set("usersCollection",usersCollection)
    console.log("connected to database");
})
.catch((err)=>console.log("database error:"+err))


const userApp = require('./apis/usersApi')
const audioApp = require('./apis/audioSongsApi')
const videoApp = require('./apis/videoSongsApi')

app.use('/usersApi',userApp)
app.use('/audioSongs',audioApp)
app.use('/videoSongs',videoApp)

const invalidPathHandlerMiddleWare = (request,response,next)=>{
    //console.log("Error")
    response.send({message:"Invalid Path"})
}



app.use("*",invalidPathHandlerMiddleWare)


const errorHandlerMiddleWare = (error,request,response,next)=>{
    response.send({message:error.message})
}
app.use(errorHandlerMiddleWare);
