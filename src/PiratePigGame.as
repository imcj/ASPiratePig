package  {
    import flash.geom.Point;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.getQualifiedClassName;

    import flash.media.Sound;
    import flash.text.TextField;
    
    public class PiratePigGame extends MovieClip
    {
        static public var NUM_ROWS:int = 8;
        static public var NUM_COLUMNS:int = 8;
        
        var tiles:Array = new Array();
        var animals:Array = new Array();
        var selectedTile:Animal;
        var cacheMouse:Point;
        var needToCheckMatches:Boolean = false;
        var currentScore:int = 0;

        var sound3:Sound;
        var sound4:Sound;
        var sound5:Sound;
        var soundTheme:Sound;

        public function PiratePigGame() {
            // constructor code
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        function init(e:Event):void
        {
            removeChildAt(0);
            initializeVariables();
            newGame();
        }
        
        function initializeVariables()
        {
            animals.push(Bear);
            animals.push(Bunny);
            animals.push(Carrot);
            animals.push(Lemon);
            animals.push(Panda);
            animals.push(PiratePig);

            var i:int, j:int;
            for (i = 0; i < NUM_ROWS; i++) {
                tiles[i] = new Array();
                for (j = 0; j < NUM_COLUMNS; j++) {
                    tiles[i][j] = null;
                }
            }

            sound3 = new Sound3();
            sound4 = new Sound4();
            sound5 = new Sound5();
            soundTheme = new SoundTheme();
            
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        function newGame():void
        {
            soundTheme.play();

            var i:int, j:int;
            for (i = 0; i < NUM_ROWS; i++) {
                for (j = 0; j < NUM_COLUMNS; j++) {
                    removeTile(i, j, false);
                }
            }
            
            for (i = 0; i < NUM_ROWS; i++) {
                for (j = 0; j < NUM_COLUMNS; j++) {
                    addTile(i, j, false);
                }
            }
        }
        
        function addTile(row:int, column:int, animate:Boolean)
        {
            var random_animal:int = Math.round(Math.random() * (animals.length -1));
            var tile = new animals[random_animal]();
            var position = getPosition(row, column);
            tile.x = position.x;
            tile.y = position.y;
            tile.row = row;
            tile.column = column;
            tiles[row][column] = tile;

            addChild(tile);

            needToCheckMatches = true;
        }
        
        function removeTile(row:int, column:int, animate:Boolean)
        {
            var tile = tiles[row][column];
            
            if (tile != null) {
                tile.remove(animate);
                // usedTiles.push(tile);
            }
            
            tiles[row][column] = null;
        }

        function swapTile(tile:Animal, targetRow:int, targetColumn:int):void
        {
            if (targetColumn < 0 || targetColumn >= NUM_COLUMNS ||
                targetRow    < 0 || targetRow >= NUM_ROWS)
                return;


            var targetTile = tiles[targetRow][targetColumn];

            if (null == targetTile || targetTile.moving)
                return;
            
            tiles[targetRow][targetColumn] = tile;
            tiles[tile.row][tile.column] = targetTile;
            
            if (findMatches(true, false).length > 0 ||
                findMatches(false, false).length > 0) {
                
                targetTile.row = tile.row;
                targetTile.column = tile.column;
                tile.row = targetRow;
                tile.column = targetColumn;
                var targetTilePosition = getPosition(targetTile.row, targetTile.column);
                var tilePosition = getPosition(tile.row, tile.column);
                
                targetTile.moveTo(0.3, targetTilePosition.x, targetTilePosition.y);
                tile.moveTo(0.3, tilePosition.x, tilePosition.y);
                
                needToCheckMatches = true;
                
            } else {
                tiles[targetRow][targetColumn] = targetTile;
                tiles[tile.row][tile.column] = tile;
            }
        }

        function dropTiles():void
        {
            var column:int = 0, row:int = 0;
            for (column = 0; column < NUM_COLUMNS; column++) {
                var spaces:int = 0;
                
                for (row = 0;row < NUM_ROWS; row++) {
                    var index:int = (NUM_ROWS - 1) - row;
                    var tile:Animal = tiles[index][column];
                    
                    if (tile == null) {
                        spaces++;
                    } else {
                        if (spaces > 0) {
                            var position = getPosition (index + spaces, column);
                            tile.moveTo (0.15 * spaces, position.x,position.y);
                            
                            tile.row = index + spaces;
                            tiles[index + spaces][column] = tile;
                            tiles[index][column] = null;
                            needToCheckMatches = true;
                        }
                    }
                }
                
                for (var i:int = 0; i < spaces; i++) {
                    row = (spaces - 1) - i;
                    addTile(row, column, true);
                }
                
            }
        }

    function findMatches (byRow:Boolean, accumulateScore:Boolean=true):Array
    {
        var matchedTiles:Array = new Array();
        var max:int;
        var secondMax:int;
        var index:int = 0, secondIndex = 0;
        
        if (byRow) {
            max = NUM_ROWS;
            secondMax = NUM_COLUMNS;
        } else {
            max = NUM_COLUMNS;
            secondMax = NUM_ROWS;
        }
        
        for (index = 0; index < max; index++) {
            var matches:int = 0;
            var foundTiles  = new Array();
            var previousType:String = "";
            
            for (secondIndex = 0; secondIndex < secondMax; secondIndex++) {
                var tile:Animal;
                if (byRow)
                    tile = tiles[index][secondIndex];
                else
                    tile = tiles[secondIndex][index];

                var tileName = flash.utils.getQualifiedClassName(tile);
                
                if (tile != null && !tile.moving) {
                    if (previousType == "") {
                        previousType = tileName;
                        foundTiles.push(tile);
                        continue;
                    } else if (tileName == previousType) {
                        foundTiles.push (tile);
                        matches++;
                    }
                }
                
                if (tile == null || tile.moving || tileName != previousType || 
                    secondIndex == secondMax - 1) {
                    if (matches >= 2 && previousType != "") {
                        if (accumulateScore) {
                            if (matches > 3) {
                                sound5.play ();
                            } else if (matches > 2) {
                                sound4.play ();
                            } else {
                                sound3.play ();
                            }
                            currentScore += int(Math.pow(matches, 2) * 50);
                        }
                        matchedTiles = matchedTiles.concat (foundTiles);
                    }
                    matches = 0;
                    foundTiles = new Array();
                    
                    if (tile == null || tile.moving) {    
                        needToCheckMatches = true;
                        previousType = "";
                    } else {
                        previousType = tileName;
                        foundTiles.push(tile);
                    }
                }
            }
        }
        
        return matchedTiles;
        
    }
        
        function getPosition(row:int, column:int):Point
        {
            return new Point(column * 69, row * 69);
        }

        function onEnterFrame(e:Event):void
        {
            if (!needToCheckMatches)
                return;
            
            var tile:Animal;
            var matchedTiles:Array = new Array();
            var size:int;

            matchedTiles = matchedTiles.concat(findMatches(true));
            matchedTiles = matchedTiles.concat(findMatches(false));
            size = matchedTiles.length;
            
            for (var i:int = 0; i < size; i++) {
                tile = matchedTiles[i] as Animal;
                removeTile(tile.row, tile.column, true);
            }
            
            if (matchedTiles.length > 0) {
                (parent.getChildByName("score") as flash.text.TextField).text = new String(currentScore);
                dropTiles ();
            }
        
        }
        
        function onMouseDown(e:MouseEvent):void
        {
            if (e.target is Animal) {
                selectedTile = e.target as Animal;
                cacheMouse = new Point(e.stageX, e.stageY);
            } else {
                selectedTile = null;
                cacheMouse = null;
            }
        }
        
        function onMouseUp(e:MouseEvent):void
        {
            if (cacheMouse == null || selectedTile == null ||
                selectedTile.moving) {

                cacheMouse = null;
                selectedTile = null;
                return;
            }
            
            var differenceX:Number = e.stageX - cacheMouse.x;
            var differenceY:Number = e.stageY - cacheMouse.y;
            
            if (Math.abs(differenceX) > 10 || Math.abs(differenceY) > 10) {
                
                var swapToRow:int = selectedTile.row;
                var swapToColumn:int = selectedTile.column;
                
                if (Math.abs(differenceX) > Math.abs(differenceY))
                    if (differenceX < 0)
                        swapToColumn --;
                    else
                        swapToColumn ++;
                else
                    if (differenceY < 0)
                        swapToRow --;
                        
                    else
                        swapToRow ++;
                
                swapTile(selectedTile, swapToRow, swapToColumn);
            }
        }
    }
    
}
