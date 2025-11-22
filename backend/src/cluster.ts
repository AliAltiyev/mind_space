import cluster from 'cluster';
import os from 'os';
import dotenv from 'dotenv';

dotenv.config();

const numCPUs = os.cpus().length;
const workers = parseInt(process.env.WORKERS || numCPUs.toString());

if (cluster.isPrimary) {
    console.log(`Master process ${process.pid} is running`);
    console.log(`Starting ${workers} workers...`);

    // Fork workers
    for (let i = 0; i < workers; i++) {
        cluster.fork();
    }

    // Handle worker exit
    cluster.on('exit', (worker, code, signal) => {
        console.log(`Worker ${worker.process.pid} died with code ${code} and signal ${signal}`);
        console.log('Starting a new worker...');
        cluster.fork();
    });

    // Handle worker online
    cluster.on('online', (worker) => {
        console.log(`Worker ${worker.process.pid} is online`);
    });
} else {
    // Workers can share any TCP connection
    // In this case, it's an HTTP server
    require('./index');
    console.log(`Worker ${process.pid} started`);
}


