import de.bezier.guido.*;

public final static int NUM_ROWS = 20;
public final static int NUM_COLS = 20;
private MSButton[][] buttons;
private ArrayList <MSButton> bombs;
private int myBombs = 3;

void setup ()
{
    size(400, 400);
    textAlign(CENTER,CENTER);
    
    // make the manager
    Interactive.make( this );
    
    //your code to initialize buttons goes here
    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    for(int i = 0; i < NUM_ROWS; i++) {
      for(int j = 0; j < NUM_COLS; j++) {
        buttons[i][j] = new MSButton(i, j);
      }
    }
   
    bombs = new ArrayList <MSButton>();
    setBombs(myBombs);
}
public void setBombs(int nBombs)
{
    //fills ArrayList with random locations of bombs
    while(nBombs > 0) {
        int r = (int)(NUM_ROWS*Math.random());
        int c = (int)(NUM_COLS*Math.random());
        if(!bombs.contains(buttons[r][c]))
            bombs.add(new MSButton(r,c));
            nBombs--;
    }
}

public void draw ()
{
    background( 0 );
    if(isWon())
        displayWinningMessage();
}
public boolean isWon()  //if unclicked button does not contain a bomb, then not won
{
    for(MSButton[] but : buttons) {
      for(MSButton b : but) {
        if( !b.isClicked() ) {
            if( !bombs.contains(b) )
                return false;
        }
      }
    }    
    return true;
}
public void displayLosingMessage()
{
    for(MSButton bomb : bombs) {
        bomb.setClicked();
    }
    fill(0, 255, 0);
    textSize(32);
    text("You Lose!", 200, 200);
}
public void displayWinningMessage()
{
    fill(0, 0, 255);
    textSize(32);
    text("You Win!", 200, 200);
}

public class MSButton
{
    private int r, c;
    private float x,y, width, height;
    private boolean clicked, marked;
    private String label;
    
    public MSButton ( int rr, int cc )
    {
        width = 400/NUM_COLS;
        height = 400/NUM_ROWS;
        r = rr;
        c = cc; 
        x = c*width;
        y = r*height;
        label = "";
        marked = clicked = false;
        Interactive.add( this ); // register it with the manager
    }
    public boolean isMarked()
    {
        return marked;
    }
    public boolean isClicked()
    {
        return clicked;
    }
    // called by manager
    
    public void setClicked()
    {
        clicked = true;
    }
    public void mousePressed () 
    {
        int n = countBombs(r,c);
        clicked = true;
        if( mouseButton == RIGHT ) {
            marked = true;              //right-click to mark button
            clicked = false;
        }
        else if( bombs.contains(this) )
            displayLosingMessage();     //if button clicked contains bomb, lose game
        else if(n > 0)                  //if bombs in neighboring buttons, display number
            label += n;
        else {                          //if no bombs in neighboring buttons
            for(int row = r-1; row <= r+1; row++) {
                for(int col = c-1; col <= c+1; col++) {
                    if( row==r && col==c )  //mousePressed not called for button itself
                        continue;
                    //recursively call mousePressed for neighboring buttons
                    if(isValid(row, col) && !buttons[row][col].isClicked() && !buttons[row][col].isMarked())
                        buttons[row][col].mousePressed();
                }
            }
        }    
    }

    public void draw () 
    {    
        if (marked)                                 //white if marked (a.k.a flagged)
            fill(255);
        else if( clicked && bombs.contains(this) )  //red if clicked a button with a bomb
            fill(255,0,0);
        else if(clicked)                            //dark grey if clicked a button with no bomb
            fill( 150 );
        else                                        //unclicked and unmarked
            fill( 200 );

        rect(x, y, width, height);
        fill(0);
        text(label,x+width/2,y+height/2);
    }
    public void setLabel(String newLabel)
    {
        label = newLabel;
    }
    public boolean isValid(int r, int c)  //checks if row and col numbers exist for 2d array
    {
        if( r>=0 && r<NUM_ROWS ) {
          if( c>=0 && c<NUM_COLS )
            return true;
        }
        return false;
    }
    public int countBombs(int row, int col)  //counts bombs in neighboring 8 buttons
    {
        int numBombs = 0;
        for(int i = row-1; i <= row+1; i++) {
            for(int j = col-1; j <= col+1; j++) {
                if( i==row && j==col )  //doesn't check square itself
                    continue;
                if(isValid(i, j) && bombs.contains(buttons[i][j]))
                    numBombs++;
            }
        }
        return numBombs;
    }
}
