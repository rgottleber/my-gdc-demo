export interface Frame {
    firstPipe: PipePair;
    secondPipe: PipePair;
    gameOver: boolean;
    gameStarted: boolean;
    width: number;
    height: number;
    score: number;
    ground: Ground;
    bird: Bird;
}
export interface PipePair {
    topPipe: Pipe;
    bottomPipe: Pipe;
    show: boolean;
    left: number;
    width: number;
}

export interface Pipe {
    top: number;
    height: number;
}

export interface Ground {
    height: number;
}

export interface Bird {
    top: number;
    left: number;
    size: number;
}
export class GameController {
    private frame: Frame;

    private velocity = 0;

    constructor(
        public readonly height = 1200,
        public readonly width = 800,
        public readonly pipeWidth = 100,
        public readonly pipeGap = 350,
        public readonly minTopForTopPipe = 70,
        public readonly maxTopForTopPipe = 350,
        public readonly generateNewPipePercent = 0.6,
        public readonly speed = 7,
        public readonly groundHeight = 20,
        public readonly birdX = 40,
        public readonly birdSize = 100,
        public readonly gravity = 1.7,
        public readonly jumpVelocity = 15,
        public readonly slowVelocityBy = 0.6
    ) { }
    public newGame(multiplier: number) {
        let firstPipe = this.createPipe(true);
        let secondPipe = this.createPipe(false);

        this.frame = {
            firstPipe,
            secondPipe,
            gameOver: false,
            gameStarted: false,
            width: this.width,
            height: this.height,
            score: 0,
            ground: {
                height: this.groundHeight,
            },
            bird: {
                left: this.birdX,
                top: this.height / 2 - this.birdSize / 2,
                size: this.birdSize,
            }
        };
        return this.frame;
    }

    private randomYForTopPipe(): number {
        return (
            this.minTopForTopPipe +
            (this.maxTopForTopPipe - this.minTopForTopPipe) * Math.random()
        );
    }
    private createPipe(show: boolean): PipePair {
        const height = this.randomYForTopPipe();

        return {
            topPipe: {
                top: 0,
                height,
            },
            bottomPipe: {
                top: height + this.pipeGap,
                height: this.height,
            },
            left: this.width - this.pipeWidth,
            width: this.pipeWidth,
            show,
        };
    }

    private movePipe(pipe: PipePair, otherPipe: PipePair) {
        if (pipe.show && pipe.left <= this.pipeWidth * -1) {
            pipe.show = false;
            return pipe;
        }

        if (pipe.show) {
            pipe.left -= this.speed;
        }

        if (
            otherPipe.left < this.width * (1 - this.generateNewPipePercent) &&
            otherPipe.show &&
            !pipe.show
        ) {
            return this.createPipe(true);
        }

        return pipe;
    }

    public nextFrame(multiplier: number) {
        if (this.frame.gameOver || !this.frame.gameStarted) {
            return this.frame;
        }
        this.frame.firstPipe = this.movePipe(
            this.frame.firstPipe,
            this.frame.secondPipe
        );
        this.frame.secondPipe = this.movePipe(
            this.frame.secondPipe,
            this.frame.firstPipe
        );

        if (this.hasCollidedWithPipe()) {
            this.frame.gameOver = true;
            return this.frame;
        }

        if (
            this.frame.bird.top >=
            this.height - this.groundHeight - this.birdSize) {
            this.frame.bird.top = this.height - this.groundHeight - this.birdSize;
            this.frame.gameOver = true;
            return this.frame;
        }

        //Gravity
        if (this.velocity > 0) {
            this.velocity -= this.slowVelocityBy;
        }
        this.frame.bird.top += Math.pow(this.gravity, 2) - this.velocity;

        // Add score
        if (this.frame.firstPipe.left + this.pipeWidth == this.birdX - this.speed - 3) {
            this.frame.score = +this.frame.score + +multiplier;
        }

        // Add Score
        if (
            this.frame.secondPipe.left + this.pipeWidth ==
            this.birdX - this.speed - 3
        ) {
            this.frame.score = +this.frame.score + +multiplier;
        }

        return this.frame;
    }

    public jump() {
        if (this.velocity <= 0) {
            this.velocity += this.jumpVelocity;
        }
    }

    private checkPipe(left: number) {
        return (
            left <= this.birdX + this.birdSize && left + this.pipeWidth >= this.birdX
        )
    }

    private hasCollidedWithPipe() {
        if (
            this.frame.firstPipe.show &&
            this.checkPipe(this.frame.firstPipe.left)
        ) {
            return !(
                this.frame.bird.top > this.frame.firstPipe.topPipe.height &&
                this.frame.bird.top + this.birdSize <
                this.frame.firstPipe.bottomPipe.top
            );
        }

        if (
            this.frame.secondPipe.show &&
            this.checkPipe(this.frame.secondPipe.left)
        ) {
            return !(
                this.frame.bird.top > this.frame.secondPipe.topPipe.height &&
                this.frame.bird.top + this.birdSize <
                this.frame.secondPipe.bottomPipe.top
            );
        }

        return false;
    }

    public start(multiplier: number) {
        this.newGame(multiplier);
        this.frame.gameOver = false;
        this.frame.gameStarted = true;
        return this.frame;
    }

}