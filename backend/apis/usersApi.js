const exp = require('express');
const userApp = exp.Router()
const expressAsyncHandler = require("express-async-handler")
const bcryptjs = require('bcryptjs');
const jsonWebToken = require("jsonwebtoken")
const date = require('date-and-time') 


userApp.use(exp.json())

userApp.post('/create-user', expressAsyncHandler(async (request, response) => {
    const userCollectionObj = request.app.get("usersCollection")
    const newUser = request.body;
    let userOfDb = await userCollectionObj.findOne({ username: newUser.username })

    if (userOfDb != null) {
        response.status(200).send({ status: false })
    }
    else {
        newUser['favouriteAudios'] = [];
        newUser['favouriteVideos'] = [];
        newUser['RecentlyPlayedAudios'] = [];
        newUser['RecentlyPlayedVideos'] = [];
        let hashPassword = await bcryptjs.hash(newUser.password, 5);
        newUser.password = hashPassword;
        await userCollectionObj.insertOne(newUser)
        response.send({ status: true })
    }
}))

userApp.post('/login-user', expressAsyncHandler(async (request, response) => {
    const userCollectionObj = request.app.get("usersCollection");
    let userDetails = request.body;
    let userExist = await userCollectionObj.findOne({ username: userDetails.username })
    if (userExist == null) {
        response.send({ message: "Username doesn't exist", status: false })
    }
    else {
        console.log("password")
        let passwaordCompare = await bcryptjs.compare(userDetails.password, userExist.password)
        if (passwaordCompare == false) {
            response.send({ status: false })
        }
        else {
            let token = jsonWebToken.sign({ username: userDetails.username }, "narasimha", { expiresIn: 365 * 24 * 60 * 60 })
            response.send({ status: true, token: token })
        }
    }
}))

userApp.get('/getFavouriteAudios/:id', expressAsyncHandler(async (request, response) => {
    const userCollectionObj = request.app.get("usersCollection");
    let username = request.params.id;
    let userExist = await userCollectionObj.findOne({ username: username })
    let favouriteAudios = [];
    for (let i of userExist["favouriteAudios"]) {
        favouriteAudios.push(i)
    }
    response.send(favouriteAudios)
}))

userApp.put('/markFavouriteAudios/:id', expressAsyncHandler(async (request, response) => {
    const userCollectionObj = request.app.get("usersCollection");
    let userDetails = request.body;
    let userExist = await userCollectionObj.findOne({ username: userDetails.username })
    let favouritesList = userExist.favouriteAudios
    if (favouritesList.includes(request.params.id)) {
        favouritesList = favouritesList.filter(item => item !== request.params.id);
        console.log("removed")
    }
    else {
        favouritesList.push(request.params.id)
        console.log("added")
    }
    let updateFavourites = await userCollectionObj.updateOne({ username: userDetails.username }, { $set: { "favouriteAudios": favouritesList } })
    response.send({ message: true })
}))

userApp.get('/getFavouriteVideos/:id', expressAsyncHandler(async (request, response) => {
    const userCollectionObj = request.app.get("usersCollection");
    let username = request.params.id;
    let userExist = await userCollectionObj.findOne({ username: username })
    let favouriteVideos = [];
    for (let i of userExist["favouriteVideos"]) {
        favouriteVideos.push(i)
    }
    response.send(favouriteVideos)
}))

userApp.put('/markFavouriteVideos/:id', expressAsyncHandler(async (request, response) => {
    const userCollectionObj = request.app.get("usersCollection");
    let userDetails = request.body;
    let userExist = await userCollectionObj.findOne({ username: userDetails.username })

    let favouritesList = userExist.favouriteVideos
    if (favouritesList.includes(request.params.id)) {
        favouritesList = favouritesList.filter(item => item !== request.params.id);
    }
    else {
        favouritesList.push(request.params.id)
    }
    let updateFavourites = await userCollectionObj.updateOne({ username: userDetails.username }, { $set: { "favouriteVideos": favouritesList } })
    response.send({ message: true })
}))

userApp.put('/RecentlyPlayedAudios/:id', expressAsyncHandler(async (request, respnse) => {
    const userCollectionObj = request.app.get("usersCollection");
    let userDetail = request.body;
    let userExist = await userCollectionObj.findOne({ username: userDetail.username })
    let recentyPlayedAudios = userExist['RecentlyPlayedAudios']
    let song = request.params.id;
    let upload = false;
    const now  =  new Date(); 
    const value = date.format(now,'YYYY/MM/DD HH:mm:ss');
    for (let i in recentyPlayedAudios) {
        if (recentyPlayedAudios[i].song === song) {
            recentyPlayedAudios[i].time = value;
            upload = true;
            break;
        }
    }
    if (!upload) {
        let newdetails = { song: song, time: value};
        recentyPlayedAudios.push(newdetails)
    }
    let updatedRecentlyPlayed = await userCollectionObj.updateOne({ username: userDetail.username }, { $set: { "RecentlyPlayedAudios": recentyPlayedAudios } })
    respnse.send({ message: "Recently played" })
}))

userApp.get('/getRecentlyPlayedAudios/:id', expressAsyncHandler(async (request, respnse) => {
    const userCollectionObj = request.app.get("usersCollection");
    let username = request.params.id;
    let RecentlyPlayed = await userCollectionObj.findOne({ username: username })
    respnse.send(RecentlyPlayed.RecentlyPlayedAudios)
}))

userApp.get('/getRecentlyPlayedVideos/:id', expressAsyncHandler(async (request, respnse) => {
    const userCollectionObj = request.app.get("usersCollection");
    let username = request.params.id;
    let RecentlyPlayed = await userCollectionObj.findOne({ username: username })
    console.log(RecentlyPlayed.RecentlyPlayedVideos)
    respnse.send(RecentlyPlayed.RecentlyPlayedVideos)
}))


userApp.put('/RecentlyPlayedVideos/:id', expressAsyncHandler(async (request, respnse) => {
    const userCollectionObj = request.app.get("usersCollection");
    let userDetail = request.body;
    let userExist = await userCollectionObj.findOne({ username: userDetail.username })
    let recentlyPlayedVideos = userExist['RecentlyPlayedVideos']
    let song = request.params.id;
    let upload = false;
    const now  =  new Date(); 
    const value = date.format(now,'YYYY/MM/DD HH:mm:ss'); 
    for (let i in recentlyPlayedVideos) {
        if (recentlyPlayedVideos[i].song === song) {
            recentlyPlayedVideos[i].time = value;
            upload = true;
            break;
        }
    }
    if (!upload) {
        let newdetails = { song: song, time: value };
        recentlyPlayedVideos.push(newdetails)
    }
    let updatedRecentlyPlayed = await userCollectionObj.updateOne({ username: userDetail.username }, { $set: { "RecentlyPlayedVideos": recentlyPlayedVideos } })
    respnse.send({ message: "Recently played" })
}))

module.exports = userApp;