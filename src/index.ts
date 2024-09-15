import express, { Request, Response } from 'express';
import cors from 'cors';

const app = express()
const corsOptions = cors()
app.use(corsOptions)

app.get('/', (req: Request, res: Response) => {
    const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
    console.log("New Request from", ip)
    res.status(200).json({ message: "Hello from backend! 8080", ip: ip })
});

app.listen(8080, () => {
    console.log("listen on port 8080")
});
