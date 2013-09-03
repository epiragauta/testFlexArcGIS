package com.esri.ags.samples
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.SpatialReference;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polyline;
	import com.esri.ags.layers.FeatureLayer;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.layers.supportClasses.FeatureCollection;
	import com.esri.ags.layers.supportClasses.LayerDetails;
	import com.esri.ags.renderers.SimpleRenderer;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.Symbol;
	import com.esri.ags.utils.JSONUtil;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.core.DPIClassification;
	
	import org.osmf.logging.Logger;
	
	
	public class JSONFeatureLayerLocal
	{
		// variables
		private var _loader:URLLoader;
		
		// properties
		public var url:String;
		public var map:Map;
		
		private var graphicLayer:GraphicsLayer
		private var path:Array;
		private var numPointsInPath:Number;
		private var idPoint:Number;
		private var mapPoint:MapPoint;
		private var graphicMapPoint:Graphic;
		
		var featureSet:FeatureSet;
		
		private var idPoints:Array;
		private var paths:Array;
		private var mapPoints:Array;
		private var graphicMapPoints:Array;
		
		public function JSONFeatureLayerLocal()
		{
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, loader_completeHandler);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, loader_httpStatusHandler);
		}
		
		// methods
		public function fetch():void
		{
			var request:URLRequest = new URLRequest();
			request.url = url;
			
			_loader.load(request);
		}
		
		// event handlers
		private function loader_completeHandler(event:Event):void
		{
			var obj:Object =  JSONUtil.decode(_loader.data);
			
			var a:Number = 1;
			createFeatureLayerFromJSON(obj);
			
		}
		
		private function loader_ioErrorHandler(event:IOErrorEvent):void
		{
			Alert.show(event.text, "Application IOError");
		}
		
		private function loader_securityErrorHandler(event:SecurityErrorEvent):void
		{
			Alert.show(event.text, "Application Security Error");
		}
		
		protected function loader_httpStatusHandler(event:HTTPStatusEvent):void
		{
			if (event.status == 404)
			{
				Alert.show("Unable to load the following resource \n" + url, "http error");
			}
		}
		
		private function createFeatureLayerFromJSON(obj:Object):void{
			
			var identLineSymbol:Symbol;
			identLineSymbol = new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID,0xff3300,0.9,3);
			
			var featureLayer:FeatureLayer = new FeatureLayer();
			featureLayer.name = "Red_Troncal";
			featureLayer.spatialReference = map.spatialReference;
			featureLayer.renderer = new SimpleRenderer(identLineSymbol);
			var layerDetails:LayerDetails = new LayerDetails();
			featureSet = FeatureSet.fromJSON(obj);
			featureLayer.featureCollection = new FeatureCollection(featureSet, layerDetails);
			
			featureLayer.visible = true;
			map.addLayer(featureLayer);
			
			graphicLayer = new GraphicsLayer();
			graphicLayer.id="myGraphicLayer";
			map.addLayer(graphicLayer);
			
			var numFeatures:Number = featureSet.features.length;
			numPointsInPath = 0;
			var graphic:Graphic;
			var polyline:Polyline;
			
			paths = new Array();
			mapPoints = new Array();
			graphicMapPoints = new Array();
			idPoints = new Array();
			idPoint = 0;
			for (var i:Number = 0; i < numFeatures; i++){
				graphic = featureSet.features[i];
				polyline = (graphic.geometry as Polyline);
				
				if (polyline.paths[0].length > numPointsInPath){
					numPointsInPath = polyline.paths[0].length;	
				}
				// mapPoints.push(polyline.paths[0][0]);
				graphicMapPoint = new Graphic(polyline.paths[0][0]);
				graphicMapPoint.symbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_DIAMOND, 22, 0x009933);
				graphicLayer.add(graphicMapPoint);
				graphicMapPoints.push(graphicMapPoint);
				idPoints.push(idPoint);
			}
			
			
			//path = polyline.paths[0];
			//numPointsInPath = path.length;
			//idPoint = 0;
			//mapPoint = path[idPoint];
			
			
			//[Embed(='assets/runner.png')]			
			//var picEmbeddedClass:Class;
			//var pictureMarker:PictureMarkerSymbol = new PictureMarkerSymbol(picEmbeddedClass);
						
			
			var minuteTimer:Timer = new Timer(350, numPointsInPath-1);
			
			// designates listeners for the interval and completion events
			minuteTimer.addEventListener(TimerEvent.TIMER, onTick);
			minuteTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			
			// starts the timer ticking
			minuteTimer.start();
		}
		
		public function onTick(event:TimerEvent):void 
		{
			idPoint++;
			var iFeat:Number = 0;
			for each (var g:Graphic  in graphicMapPoints){								
				
				graphicLayer.remove(g);
				mapPoint = featureSet.features[iFeat].geometry.paths[0][idPoints[iFeat]];
				if (mapPoint){
					graphicMapPoint = g;
					graphicMapPoint.geometry = mapPoint;
					graphicLayer.add(graphicMapPoint);
					graphicMapPoints[iFeat] = graphicMapPoint;
				}else{
					graphicLayer.add(g);
				}
				idPoints[iFeat] = idPoints[iFeat] +1;
				if (idPoints[iFeat] == featureSet.features[iFeat].geometry.paths[0].length){
					idPoints[iFeat] = 0;
				}
					
				iFeat++;
			}								
			
		}
		
		public function onTimerComplete(event:TimerEvent):void
		{
			trace("Time's Up!");
		}
		
		public function clearMap():void{
			
			map.removeLayer(map.getLayer(map.layerIds[map.layerIds.length-1]));
			map.removeLayer(map.getLayer(map.layerIds[map.layerIds.length-1]));
		}
		
	}
}