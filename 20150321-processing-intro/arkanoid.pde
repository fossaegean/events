PVector paddle_position, ball_position, ball_speed; // διανύσματα θέσης ρακέτας και μπάλας, διάνυσμα ταχύτητας μπάλας
int width = 640; // πλάτος παραθύρου
int height = 480; // ύψος παραθύρου
int life; // αριθμός ζωών που απομένουν
int ball_size = 10; // μέγεθος μπάλας
int paddle_rx = 40; // μήκος ρακέτας
int paddle_ry = 8; // πλάτος ρακέτας
int brick_rx = 32; // ακτίνα x του τούβλου
int brick_ry = 8; // ακτίνα y του τούβλου
int brick_top_line=50;
int brick_bottom_line=100;
int n = width / (2*brick_rx);
int m = abs(brick_top_line-brick_bottom_line) / (2*brick_ry);
int empty = width % (2*brick_rx);

class Brick {
  int center_x, center_y;
  int rx = brick_rx;
  int ry = brick_ry;

  Brick(int c_x, int c_y) {// constructor: φτιάχνει ένα τούβλο παίρνοντας ως όρισμα το κέντρο του
    center_x = c_x;
    center_y = c_y;
  }

  void draw() {// ζωγραφίζει το τούβλο (αντικείμενο)
    rectMode(RADIUS);
    strokeWeight(2);
    rect(center_x, center_y, rx, ry);
  }

  int left() {
    return center_x - rx;
  }
  int right() {
    return center_x + rx;
  }
  int top() {
    return center_y - ry;
  }
  int bottom() {
    return center_y + ry;
  }
}

ArrayList<Brick> bricks = new ArrayList<Brick>(); // ArrayList με τα τούβλα

void setup() {
  size(width, height); // VGA
  smooth();
  game_reset(); // αρχικοποίηση παιχνιδιού
}

void game_reset() { // αρχικοποίηση παιχνιδιού
  paddle_position = new PVector(width/2, height-20); // αρχική θέση ρακέτας
  new_ball();  
  life = 3;
  // χτίσιμο του τοίχου
  for (int i=0; i<n; i++) { // για κάθε τούβλο της σειράς i
    for (int j=0; j<m; j++) { // για κάθε τούβλο της στήλης j
      bricks.add(new Brick((empty/2)+(2*i+1)*brick_rx, brick_bottom_line-(2*j+1)*brick_ry)); // φτιάχνω ένα νέο τούβλο
    }
  }
  fill(255);
  loop();
}

void new_ball() {
  ball_position = new PVector(width/2, brick_bottom_line+20); // αρχική θέση μπάλας
  ball_speed = new PVector(1, 2); // αρχική ταχύτητα μπάλας
}

void draw() {
  background(155);
  score();
  draw_ball(); // συνάρτηση που σχεδιάζει τη μπάλα
  draw_bricks(); // συνάρτηση που σχεδιάζει τα τούβλα
  draw_paddle(); // συνάρτηση που σχεδιάζει τη ρακέτα
}

void score() {
  fill(0);
  textSize(16);
  text("Lives: " + life, 10, 20);
  fill(255);
}

void draw_ball() { // συνάρτηση που σχεδιάζει τη μπάλα
  strokeWeight(1); // το περίγραμμα της μπάλας είναι 1px
  ellipse(ball_position.x, ball_position.y, ball_size, ball_size); // η μπάλα
  bounce(); // συνάρτηση που ελέγχει αν η μπάλα αναπηδά
  if (ball_position.y>height) loose();
  ball_position.add(ball_speed); // ανανέωση της θέσης της μπάλας
}

void draw_bricks() {// ζωγραφίζει όλα τα τούβλα που βρίσκονται στο ArrayList
  for (Brick a_brick : bricks) {
    a_brick.draw();
  }
}

void draw_paddle() { // συνάρτηση που σχεδιάζει τη ρακέτα
  rectMode(RADIUS);
  rect(paddle_position.x, paddle_position.y, paddle_rx, paddle_ry); // η ρακέτα
  update_paddle_position(); // συνάρτηση που καθορίζει τη θέση της ρακέτας
}

void update_paddle_position() { // συνάρτηση που καθορίζει τη θέση της ρακέτας
  paddle_position.x=constrain(mouseX, brick_rx, width-brick_rx); // περιορίζει (constrain) τη θέση μέσα στην οθόνη
}

void bounce() { // συνάρτηση που ελέγχει αν η μπάλα αναπηδά
  paddle_bounce(); // αναπήδηση στη ρακέτα
  side_bounce(); // αναπήδηση στα πλάγια
  top_bounce(); // αναπήδηση στο ταβάνι
  brick_bounce(); // αναπήδηση στα τούβλα
}

void paddle_bounce() { // αναπήδηση στη ρακέτα
  if ((ball_position.x>=paddle_position.x-paddle_rx) 
    && (ball_position.x<=paddle_position.x+paddle_rx) 
    && (ball_position.y>=paddle_position.y-paddle_ry-ball_size/2)) {
    if (ball_position.y>paddle_position.y-paddle_ry) { // αν η μπάλα είναι κάτω από τη ρακέτα δεν θα αναπηδήσει
      //fail
    } else {
      // διαφορετική αναπήδηση ανάλογα με το σημείο της ρακέτας που θα πέσει το μπαλάκι
      float magnitude = mag(ball_speed.x, ball_speed.y)+0.1; // μέτρο της αρχικής ταχύτητας
      ball_speed.x = map(ball_position.x - paddle_position.x, 0, paddle_rx, 0, 1) * magnitude; // νέο μέτρο ταχύτητας στον άξονα x
      ball_speed.y = -sqrt(pow(magnitude, 2) - pow(ball_speed.x, 2)); // νέο μέτρο ταχύτητας στον άξονα y
    }
  }
}

void top_bounce() { // αναπήδηση στο ταβάνι
  if (ball_position.y<=ball_size/2) {
    ball_speed.y*=-1; // αναστροφή ταχύτητας στον αξονα y
  }
}

void side_bounce() { // αναπήδηση στα πλάγια
  if ((ball_position.x<=ball_size/2) || (ball_position.x>=width-ball_size/2)) {
    ball_speed.x*=-1; // αναστροφή ταχύτητας στον άξονα x
  }
}

void brick_bounce() {
  for (int i = bricks.size ()-1; i>=0; i--) { // για κάθε τούβλο στην ArrayList
    Brick this_brick = bricks.get(i); // παίρνει το κάθε τούβλο απο τη λίστα για να εξετάσει αν χτυπήθηκε
    if (ball_position.x >= this_brick.left() - ball_size 
      && ball_position.x <= this_brick.right() + ball_size 
      && ball_position.y >= this_brick.top() - ball_size
      && ball_position.y <= this_brick.bottom() + ball_size) { // έλεγχος αν το μπαλάκι βρίσκεται μέσα στο τούβλο
      if ((ball_position.x - ball_speed.x < this_brick.left() || ball_position.x - ball_speed.x > this_brick.right()) 
        && ball_position.y - ball_speed.y > this_brick.top() 
        && ball_position.y - ball_speed.y < this_brick.bottom()) { // έλεγχος αν το μπαλάκι χτύπησε το τούβλο από το πλάι
        ball_speed.x*=-1; // αναστροφή ταχύτητας στον άξονα x
      } else {
        ball_speed.y*=-1; // αναστροφή ταχύτητας στον αξονα y
      }
      bricks.remove(i); // συνάρτηση που αφαιρεί το τούβλο από το ArrayList
      win(); // συνάρτηση που ελέγχει αν κέρδισε ο παίκτης
      break; // εφ' όσον χτύπησε ένα τούβλο βγαίνει από το for
    }
  }
}

void win() {
  if (bricks.isEmpty()) {
    background(100);
    fill(0);
    textSize(64);
    text("You won!", width/3, height/2);
    textSize(32);
    text("Press r to start a new game", width/4, height/2+100);
    noLoop();
  }
}

void loose() {
  if (life == 0) {
    background(100);
    fill(0);
    textSize(64);
    text("You lost!", width/3, height/2);
    textSize(32);
    text("Press r to start a new game", width/4, height/2+100);
    noLoop();
  } else {
    life--;
    new_ball();
    ball_position = new PVector(width/2, brick_bottom_line+20); // αρχική θέση μπάλας
    ball_speed = new PVector(1, 2); // αρχική ταχύτητα μπάλας
  }
}

void keyPressed() {
  if (key == 'r') {
    bricks.clear();
    game_reset();
  }
}

