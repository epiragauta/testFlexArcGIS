/*
MIT LICENSE:
http://www.opensource.org/licenses/mit-license.php
Copyright (c) 2011 Ben Morrow
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package
{
	import com.gasnatural.xlsxreader.Worksheet;
	import com.gasnatural.xlsxreader.XLSXLoader;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class LoadXLSXByteArrayExample extends Sprite
	{
		//Create the Excel Loader
		protected var excel_loader:XLSXLoader=new XLSXLoader();
		
		
		public function LoadXLSXByteArrayExample(bytes:ByteArray)
		{
			
			
			//Listen for when the file is loaded
			excel_loader.addEventListener(Event.COMPLETE,loadingComplete);
			
			//Load the file
			excel_loader.loadFromByteArray(bytes);
			
			
		}
		
		//Handler for loading complete
		private function loadingComplete(e:Event):void
		{
			//Access a worksheet by name ('Sheet1')
			var sheetNames:Vector.<String> = excel_loader.getSheetNames();
			
			var sheet_1:Worksheet=excel_loader.worksheet(sheetNames[0]);
			
			//Access a cell in sheet 1 and output to trace
			var xmlList:XMLList =  sheet_1.getRows("A",1,100);
			var item:XML;
			for each(item in xmlList) {
				
				trace(":: value :: " + item.children()[0].toString());
			}
			
			trace("Cell A3="+sheet_1.getCellValue("A3")) //outputs: Cell A3=Hello World;
		}
	}
}