package com.sloader
{
	import com.sloader.define.SLoaderError;
	import com.sloader.define.SLoaderEventType;
	import com.sloader.define.SLoaderFile;
	import com.sloader.define.SLoaderFileInfo;
	import com.sloader.define.SLoaderFileType;
	import com.sloader.define.SLoaderInfo;
	import com.sloader.handlers.SLoaderHandler;
	import com.sloader.handlers.SLoaderHandler_Binary;
	import com.sloader.handlers.SLoaderHandler_CSS;
	import com.sloader.handlers.SLoaderHandler_Image;
	import com.sloader.handlers.SLoaderHandler_SWF;
	import com.sloader.handlers.SLoaderHandler_XML;
	
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;

	/**
	 * SLoader资源加载管理器
	 * 
	 * #使用说明########################################################################################################################################################################
	 * 
	 * -------------------------------------
	 * 初始化加载引擎
	 * -------------------------------------
	 *  	编写如下代码：
	 * 		=============================================
	 * 		var sloader:SLoader = new SLoader("mySLoader", loaderContent=null);
	 * 		=============================================
	 * 		代码说明：
	 * 			如上代码建立一个名称为"mySLoader"的加载器,同时你也可以设置loaderContent,设置后使用该SLoader实例加载的所有文件都位于该域
	 * 			在其他文件中你可以使用SLoaderManage.instance.getSLoader(sloaderName:String):SLoader函数获取sloader实例
	 * 
	 * -------------------------------------
	 * 准备加载文件
	 * -------------------------------------
	 * 		SLoader只能加载SLoaderFile类型的文件,所以在执行加载前必须将准备加载文件转换为SLoaderFile类型
	 * 		例：比如当前需要加载 "image/scene1.png"
	 * 
	 * 		编写如下代码：
	 * 		=============================================
	 * 		var file:SLoaderFile = new SLoaderFile();
	 * 		file.name = "scene1";
	 * 		file.title = "scene1";
	 * 		file.url = "image/scene1.png";
	 * 		file.group = "scene";
	 * 		=============================================
	 * 		代码说明：
	 * 			必须填写如上四个属性才能成功将该文件纳入SLoader加载队列中。
	 *
	 *  		name(文件名称,可重复)
	 * 
	 * 			title(文件索引,如果重复,那么当本次加载设置为强制刷新的话将覆盖之前相同命名的文件)
	 * 
	 * 			url(文件地址,如果位于其他安全域则需要考虑双方安全策略)
	 * 
	 * 			group(文件加载成功后将文件纳入group属性名称的组中, 可以使用SLoader中getGroupFiles(groupName:String)获取对应组内所有文件)
	 * 
	 * --------------------------------------
	 * 执行加载文件操作
	 * --------------------------------------
	 * 		当新建好一个正确的SLoaderFile文件后就可以将其放入加载队列,然后执行execute(coverRepeatTitle:Bool)函数
	 * 
	 * 		编写如下代码：
	 * 		=============================================
	 * 		sloader.addFile(file);
	 * 		sloader.execute(true);
	 * 		=============================================
	 * 		代码说明：
	 * 			在执行execute函数中有个bool值的参数,当值为true的时候, 会对本次加载队列中的文件进行强制刷新。
	 * 			强制刷新也就是说如果加载时出现于已加载文件的title属性相同的情况,则旧的文件会被新文件替换，反之则相反
	 * 		
	 * --------------------------------------
	 * 获取加载的文件数据
	 * --------------------------------------
	 * 		当文件加载成功后我想获得某个文件,我只需要提供文件titile
	 * 		
	 * 		编写如下代码
	 * 		=============================================
	 * 		var file:SLoaderFile = sloader.getFileVO("scene1");
	 * 		var bitmap:Bitmap = SLoaderHandler_Image(file.loadInfo.loaderHandler).data;
	 *  	=============================================
	 * 		代码说明:
	 * 			我们提供对应的title并利用不同的文件处理程序来获取data就是我们想要的类型数据了
	 * 
	 * --------------------------------------
	 * 侦听事件
	 * --------------------------------------
	 * 		可以对加载过程使用事件监听器
	 * 		
	 * 		使用函数：
	 * 			public function addEventListener(type:String, handler:Function):void
	 * 			public function removeEventListener(type:String, handler:Function):void
	 * 
	 * 		支持事件位于(SLoaderEventType)
	 * 
	 * 			代码：
	 * 			=============================================
	 * 			sloader.addEventListener(XXX, myFunction);
	 * 			=============================================
	 * 			说明：
	 * 				myFunction必须包含一个参数
	 * 				不同事件抛出的消息类型是不一样的
	 * 
	 * 					比如[FILE_START]事件抛出的就是SLoaderFile,也就是说我们的事件处理函数的参数类型必须是SLoaderFile类型的
	 * 						sloader.addEventListener(SLoaderEventType.FILE_PROGRESS, myFunction);
	 * 						private function myFunction(file:SLoaderFile):void
	 * 						{
	 * 							trace("正在加载文件:"+file.name, "  已加载"+file.loaderInfo.loadedBytes);
	 * 						}
	 * 					下面列出所有事件抛出的消息类型
	 * 					SLoaderFile = FILE_START
	 *  				SLoaderFile = FILE_PROGRESS
	 *  				SLoaderFile = FILE_COMPLETE
	 *  				SLoaderError = FILE_ERROR
	 *  				SLoaderInfo = SLOADER_START
	 *  				SLoaderInfo = SLOADER_PROGRESS
	 *  				SLoaderInfo = SLOADER_COMPLETE
	 * 
	 * 				我们可以通过抛出的消息文件获取当前加载的文件信息以及加载情况,，具体请看对应消息类型文件里面有说明.
	 * 		
	 * @author number1 at 2012-07-27
	 * ############################################################################################################################################################################
	 */	
	public class SLoader
	{
		// 当前加载器加载文件所在域
		private var _loaderContext:LoaderContext;
		
		// 当前SLoader实例状态映像
		private var _loadInfo:SLoaderInfo;
		
		// 事件哈希表
		private var _eventHandlers:Dictionary;
		
		// 文件类型对应加载器
		private var _fileHandlers:Object;
		
		// 所有已经加载成功的文件
		private var _loadedFiles:Array;
		
		// 所有组分类
		private var _loadedGroups:Dictionary;
		
		// 所有已经加载的字节数
		private var _loadedBytes:Number;
		
		// 系统同时并发加载量
		private const _concurrent:uint = 2;
		
		////////////////////////////////////////////////////////////////////////
		private var _isLoading:Boolean;
		
		private var _lastProgressLoadedBytes:Object;
		
		private var _currLoadFiles:Array;
		private var _currLoadedFiles:Array;
		private var _currLoadingFiles:Array;
		private var _currLoadErrorFiles:Array;
		
		private var _currLoadFilesCount:uint;
		private var _currLoadedFilesCount:uint;
		private var _currLoadingFilesCount:uint;
		private var _currLoadErrorFilesCount:uint;
		
		private var _currTotalBytes:Number;
		private var _currLoadedBytes:Number;

		private var _currLoadPercentage:Number;
		
		private var _currLoadCover:Boolean;
		////////////////////////////////////////////////////////////////////////
		
		public function SLoader(name:String, loaderContext:LoaderContext=null)
		{
			SLoaderManage.instance.addSLoader(name, this);
			
			_loaderContext = loaderContext ? loaderContext:new LoaderContext(false, null, null);
			
			initializeEventHandler();
			initializeFileHandler();
			initializePar();
		}
		
		private function initializePar():void
		{
			_loadedFiles = [];
			
			_isLoading = false;
			
			_currLoadFiles = [];
			_currLoadingFiles = [];
			_currLoadedFiles = [];
			
			_loadedBytes = 0;
			_currLoadErrorFiles = [];
			
			_loadInfo = new SLoaderInfo();
			_loadInfo.loaderContext = _loaderContext;
			_loadInfo.currLoadingFiles = [];
			
			_lastProgressLoadedBytes = {};
			
			_loadedGroups = new Dictionary();
		}
		
		private function initializeEventHandler():void
		{
			_eventHandlers = new Dictionary();
			_eventHandlers[SLoaderEventType.FILE_COMPLETE] = [];
			_eventHandlers[SLoaderEventType.FILE_ERROR] =  [];
			_eventHandlers[SLoaderEventType.FILE_PROGRESS] = [];
			_eventHandlers[SLoaderEventType.FILE_START] = [];
			_eventHandlers[SLoaderEventType.SLOADER_COMPLETE] = [];
			_eventHandlers[SLoaderEventType.SLOADER_PROGRESS] = [];
			_eventHandlers[SLoaderEventType.SLOADER_START] = [];
		}
		
		private function initializeFileHandler():void
		{
			_fileHandlers = {};
			_fileHandlers[SLoaderFileType.SWF.toLowerCase()] = SLoaderHandler_SWF;
			_fileHandlers[SLoaderFileType.XML.toLowerCase()] = SLoaderHandler_XML;
			_fileHandlers[SLoaderFileType.PNG.toLowerCase()] = SLoaderHandler_Image;
			_fileHandlers[SLoaderFileType.JPG.toLowerCase()] = SLoaderHandler_Image;
			_fileHandlers[SLoaderFileType.BMP.toLowerCase()] = SLoaderHandler_Image;
			_fileHandlers[SLoaderFileType.CSS.toLowerCase()] = SLoaderHandler_CSS;
			_fileHandlers[SLoaderFileType.DAT.toLowerCase()] = SLoaderHandler_Binary;
		}
		
		///////////////////////////////////////////////////////////////////////////
		// loadListManage
		///////////////////////////////////////////////////////////////////////////
		public function addFile(fileVO:SLoaderFile):void
		{
			// 防止系统加载过程中将文件添加至加载列表
			checkLoadIt();
			
			// 防止出现不合法文件
			checkFileVO(fileVO);
			
			// 提示有重复可能会覆盖老文件
			if (checkRepeatFileVO(fileVO))
				trace("To Find duplicate (title) attribute of the file on use addFile method");
			
			// 成功添加
			_currLoadFiles.push(fileVO);
		}
		
		public function addFiles(files:Array):void
		{
			checkLoadIt();
			
			for (var i:int=0; i<files.length; i++)
			{
				var fileVO:SLoaderFile = files[i];
				checkFileVO(fileVO);
				if (checkRepeatFileVO(fileVO))
					trace("To Find duplicate (title) attribute of the file on use addFiles method");
				
				_currLoadFiles.push(fileVO);
			}
		}
		
		public function removeFile(fileVO:SLoaderFile):void
		{
			checkLoadIt();
			
			var index:int = _currLoadFiles.indexOf(fileVO);
			if (index != -1)
				_currLoadFiles.splice(index, 1);
		}
		
		/**
		 * @param coverRepeatTitle 当重复的title发生在本次加载文件和文件过的之间时, 是否用最新加载的文件替换旧文件
		 */		
		public function execute(coverRepeatTitle:Boolean=true):void
		{
			checkLoadIt();
			
			if (_currLoadFiles.length < 1)
				return;
			
			//////////////////////////////////
			// 初始化一些加载过程中会用到的数据
			_isLoading = true;
			
			_currLoadCover = coverRepeatTitle;
			
			currTotalBytes = 0;
			for each(var fileVO:SLoaderFile in _currLoadFiles)
			{
				if (isNaN(fileVO.size) || fileVO.size <= 0){
					currTotalBytes = Number.NaN;
					break;
				}else{
					currTotalBytes += fileVO.size;
				}
			}
			
			currLoadedBytes = 0;
			
			_currLoadPercentage = 0;
			
			_loadInfo.currTotalFilesCount = _currLoadFiles.length;
			
			_currLoadedFiles.length = 0;
			
			_currLoadErrorFiles.length = 0;

			_currLoadFilesCount = _currLoadFiles.length;
			
			_currLoadErrorFilesCount = 0;
			
			_currLoadedFilesCount = 0;
			
			//////////////////////////////////
			// 开始加载
			executeConcurrent();
		}
		
		private function executeConcurrent():void
		{
			if (!_isLoading)
				return;
			
			var rest:int = _currLoadFilesCount - _currLoadedFilesCount - _currLoadErrorFilesCount;
			while (_currLoadingFilesCount < (_concurrent>rest ? rest:_concurrent) )
			{
				// 在本次加载队列中寻找一个【不在加载中】【没有加载成功】【没有加载出错】的文件进行加载操作
				var readyFileVO:SLoaderFile = null;
				for each(var file:SLoaderFile in _currLoadFiles)
				{
					if (
						_currLoadingFiles.indexOf(file) == -1 && 
						_loadedFiles.indexOf(file) == -1 &&
						_currLoadErrorFiles.indexOf(file) == -1
					){
						_currLoadingFiles.push(file);
						_currLoadingFilesCount = _currLoadingFiles.length;
						
						readyFileVO = file;
						
						if (!_loadInfo.currLoadingFiles)
							_loadInfo.currLoadingFiles = [];
						_loadInfo.currLoadingFiles.push(file);
						
						// trace("【并发机制】新增文件下载["+file.name+"]----当前并发["+_currLoadingFiles.length+"], 系统允许最高["+(_concurrent > rest ? rest:_concurrent)+"]");
						break;
					}
				}
				
				if (readyFileVO)
					_execute(readyFileVO);
			}
		}
		
		private function _execute(fileVO:SLoaderFile):void
		{
			// 如果执行加载的文件
			//--【存在于加载出错文件列表】
			//--【存在于本次已经加载列表中】
			//--【不存在于本次加载列表】
			// 则放弃加载
			if (
				_currLoadErrorFiles.indexOf(fileVO) != -1 ||
				_currLoadedFiles.indexOf(fileVO) != -1 ||
				_currLoadFiles.indexOf(fileVO) == -1
			)
				return;
			
			var fileType:String = SLoaderHelper.getFileType(fileVO).toLowerCase();
			var loadHandlerClass:Class = _fileHandlers[fileType];
			if (!loadHandlerClass)
			{
				throw new Error("you not registered handler on ["+fileType+"]");
			}
			else
			{
				if(!getFileVO(fileVO.title) || _currLoadCover)
				{
					// 这个文件一定要执行加载操作
					var loadHandler:SLoaderHandler = new loadHandlerClass(fileVO, _loaderContext);
					loadHandler.setFileCompleteEventHandler(onFileComplete);
					loadHandler.setFileProgressEventHandler(onFileProgress);
					loadHandler.setFileStartEventHandler(onFileStart);
					loadHandler.setFileIoErrorEventHandler(onFileIoError);
					loadHandler.startLoad();
				}
				else
				{
					// 不用加载了, 直接抛出事件
					onFileComplete(fileVO);
				}
			}
		}
		
		public function stop():void
		{
			// 不再继续加载
			_isLoading = false;
			
			// 停止当前加载
			for (var i:int=0; i<_currLoadingFiles.length; i++)
			{
				var loadInfo:SLoaderFileInfo = (_currLoadingFiles[i] as SLoaderFile).loaderInfo;
				if (loadInfo)
					loadInfo.loaderHandler.stopLoad();
			}
			
			// 清除事件侦听
			initializeEventHandler();
		}
		
		///////////////////////////////////////////////////////////////////////////
		// eventManage
		///////////////////////////////////////////////////////////////////////////
		public function addEventListener(type:String, handler:Function):void
		{
			if (!_eventHandlers[type])
				throw new Error("event name["+type+"] is Invalid");
			
			_eventHandlers[type].push(handler);
		}
		
		public function removeEventListener(type:String, handler:Function):void
		{
			if (!_eventHandlers[type])
				return;
			
			var index:int = _eventHandlers[type].indexOf(handler);
			if (index != -1)
				_eventHandlers[type].splice(index, 1);
		}
		
		private function onFileStart(fileVO:SLoaderFile):void
		{
			if (_currLoadedFiles.length == 0)
				onSloaderStart();

			executeHandlers(_eventHandlers[SLoaderEventType.FILE_START], fileVO);
		}
		
		private function onFileProgress(fileVO:SLoaderFile):void
		{
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_PROGRESS], fileVO);
			onSloaderProgress(fileVO);
		}
		
		private function onFileComplete(fileVO:SLoaderFile):void
		{
			_currLoadedFiles.push(fileVO);
			
			_loadedFiles.push(fileVO);
			
			_loadInfo.currLoadedFilesCount = _currLoadedFiles.length;
			
			_loadInfo.loadedFilesCount = _loadedFiles.length;
			
			_currLoadedFilesCount = _currLoadedFiles.length;
			
			var loadingIndex:int = _currLoadingFiles.indexOf(fileVO);
			if (loadingIndex != -1)
			{
				_currLoadingFiles.splice(loadingIndex, 1);
				_currLoadingFilesCount = _currLoadingFiles.length;
				
				if (_loadInfo.currLoadingFiles)
				var infoLoadingIndex:int = _loadInfo.currLoadingFiles.indexOf(fileVO);
				if (infoLoadingIndex != -1)
					_loadInfo.currLoadingFiles.splice(infoLoadingIndex, 1);
			}
			
			var hasfile:Boolean = _currLoadFilesCount > _currLoadedFilesCount;
			_isLoading = hasfile;
			
			if (!hasfile)
				_currLoadFiles.length = 0;
			
			// 将文件纳入组，只对加载成功的文件有效，组内存在相同文件则用最新的替换旧的
			if (!_loadedGroups[fileVO.group])
				_loadedGroups[fileVO.group] = {};
			_loadedGroups[fileVO.group][fileVO.title] = fileVO;
			
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_COMPLETE], fileVO);
			
//			var rest:int = _currLoadFiles.length - _currLoadedFiles.length - _currLoadErrorFiles.length;
//			trace(fileVO.name + "-加载成功..,"+"当前并发["+_currLoadingFiles.length+"],系统允许最高["+(_concurrent>rest ? rest:_concurrent)+"]");
			executeConcurrent();
			
			if (!hasfile)
				onSloaderComplete();
		}
		
		private function onFileIoError(error:SLoaderError):void
		{
			_currLoadErrorFiles.push(error.file);
			
			_currLoadErrorFilesCount = _currLoadErrorFiles.length;
			
			var loadingIndex:int = _currLoadingFiles.indexOf(error.file);
			if (loadingIndex != -1)
			{
				_currLoadingFiles.splice(loadingIndex, 1);
				_currLoadingFilesCount = _currLoadingFiles.length;
				
				if (_loadInfo.currLoadingFiles)
					var infoLoadingIndex:int = _loadInfo.currLoadingFiles.indexOf(error.file);
				if (infoLoadingIndex != -1)
					_loadInfo.currLoadingFiles.splice(infoLoadingIndex, 1);
			}
			
			var hasfile:Boolean = _currLoadFilesCount > _currLoadedFilesCount;
			_isLoading = hasfile;
			
			executeHandlers(_eventHandlers[SLoaderEventType.FILE_ERROR], error);
			
			if (!hasfile)
				onSloaderComplete();
		}
		
		private function onSloaderStart():void
		{
			executeHandlers(_eventHandlers[SLoaderEventType.SLOADER_START], _loadInfo);
		}
		
		private function onSloaderProgress(currFileVO:SLoaderFile):void
		{
			if (isNaN(Number( _lastProgressLoadedBytes[currFileVO.title] )))
				_lastProgressLoadedBytes[currFileVO.title] = 0;
			
			_lastProgressLoadedBytes[currFileVO.title] = currFileVO.loaderInfo.loadedBytes - Number(_lastProgressLoadedBytes[currFileVO.title]);
			currLoadedBytes += Number(_lastProgressLoadedBytes[currFileVO.title]);
			loadedBytes += Number(_lastProgressLoadedBytes[currFileVO.title]);
			if (isNaN(_currTotalBytes))
			{
				currLoadPercentage += _lastProgressLoadedBytes[currFileVO.title]/currFileVO.loaderInfo.totalBytes/_currLoadFilesCount;
			}
			else
			{
				currLoadPercentage = _currLoadedBytes/_currTotalBytes;
			}
			_lastProgressLoadedBytes[currFileVO.title] = currFileVO.loaderInfo.loadedBytes;
			
			executeHandlers(_eventHandlers[SLoaderEventType.SLOADER_PROGRESS], _loadInfo);
		}
		
		private function onSloaderComplete():void
		{
			executeHandlers(_eventHandlers[SLoaderEventType.SLOADER_COMPLETE], _loadInfo);
		}
		
		private function executeHandlers(handlers:Array, file:*):void
		{
			for (var i:int=0; i<handlers.length; i++)
			{
				var handler:Function = handlers[i];
				handler(file);
			}
		}
		
		///////////////////////////////////////////////////////////////////////////
		// check
		///////////////////////////////////////////////////////////////////////////
		private function checkLoadIt():void
		{
			if (_isLoading)
				throw new Error("Refused the operation, is loaded in");
		}
		
		private function checkFileVO(fileVO:SLoaderFile):void
		{
			if (
				!fileVO.name || 
				!fileVO.url || 
				!fileVO.title || 
				!fileVO.group ||
				fileVO.group == ""
			)
				throw new Error("The fileVO parameter is incorrect");
		}
		
		private function checkRepeatFileVO(fileVO:SLoaderFile):Boolean
		{
			if (getFileVO(fileVO.title) != null)
				return true;
			
			for each(var file:SLoaderFile in _currLoadFiles)
			{
				if (file.title == fileVO.title)
					return true;
			}
			return false;
		}
		
		///////////////////////////////////////////////////////////////////////////
		// get set
		///////////////////////////////////////////////////////////////////////////	
		public function getFileVO(fileTitle:String):SLoaderFile
		{
			if (!_loadedFiles)
				return null;
			
			for each(var fileVO:SLoaderFile in _loadedFiles)
			{
				if (fileVO.title == fileTitle)
					return fileVO;
			}
			return null;
		}
		
		public function getGroupFiles(groupName:String):Object
		{
			return _loadedGroups[groupName];
		}
		
		public function get loadInfo():SLoaderInfo
		{
			return _loadInfo;
		}
		
		public function get isLoading():Boolean
		{
			return _isLoading;
		}
		
		private function set loadedBytes(value:Number):void
		{
			_loadedBytes = value;
			_loadInfo.loadedBytes = _loadedBytes;
		}
		
		private function get loadedBytes():Number
		{
			return _loadedBytes;
		}
		
		private function set currLoadedBytes(value:Number):void
		{
			_currLoadedBytes = value;
			_loadInfo.currLoadedBytes = _currLoadedBytes;
		}
		
		private function get currLoadedBytes():Number
		{
			return _currLoadedBytes;
		}
		
		private function set currTotalBytes(value:Number):void
		{
			_currTotalBytes = value;
			_loadInfo.currTotalBytes = value;
		}
		
		private function get currTotalBytes():Number
		{
			return _currTotalBytes;
		}
		
		private function set currLoadPercentage(value:Number):void
		{
			_currLoadPercentage = value;
			_loadInfo.currLoadPercentage = value;
		}
		
		private function get currLoadPercentage():Number
		{
			return _currLoadPercentage;
		}
	}
}