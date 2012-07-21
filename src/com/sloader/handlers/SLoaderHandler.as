package com.sloader.handlers
{
	import com.sloader.define.SLoaderFile;
	import com.sloader.define.SLoaderFileInfo;
	
	import flash.system.LoaderContext;

	public class SLoaderHandler
	{
		protected var _file:SLoaderFile;
		protected var _loaderContext:LoaderContext;

		protected var _onFileComplete:Function = null;
		protected var _onFileProgress:Function = null;
		protected var _onFileStart:Function = null;
		protected var _onFileIoError:Function = null;

		public function SLoaderHandler(fileVO:SLoaderFile, loaderContext:LoaderContext)
		{
			_file = fileVO;
			_file.loaderInfo = new SLoaderFileInfo();
			_file.loaderInfo.loaderHandler = this;
			_loaderContext = loaderContext;
		}

		public function setFileStartEventHandler(handler:Function):void
		{
			_onFileStart = handler;
		}

		public function setFileProgressEventHandler(handler:Function):void
		{
			_onFileProgress = handler;
		}

		public function setFileCompleteEventHandler(handler:Function):void
		{
			_onFileComplete = handler;
		}

		public function setFileIoErrorEventHandler(handler:Function):void
		{
			_onFileIoError = handler;
		}

		public function startLoad():void
		{

		}
		
		public function stopLoad():void
		{
			
		}
		
		public function unLoad():void
		{
			_file.loaderInfo.loadedBytes = 0;
		}
	}
}