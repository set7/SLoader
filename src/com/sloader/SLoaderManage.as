package com.sloader
{
	import com.sloader.loadhandlers.Binary_LoadHandler;
	import com.sloader.loadhandlers.CSS_LoadHandler;
	import com.sloader.loadhandlers.Image_LoadHandler;
	import com.sloader.loadhandlers.SWF_LoadHandler;
	import com.sloader.loadhandlers.XML_LoadHandler;
	
	import flash.utils.Dictionary;
	
	/**
	 * The SloaderManage mannagement sloader instance, you can also to use <addSLoader(sloaderName, sloaderInstance)> Add to manage the SLoader.
	 * When sloaderInstance by adding SLoaderManage, you can have access to them by the method of SLoaderManage inside.
	 * @author	number1
	 * @time	2012-07-15
	 */	
	public class SLoaderManage
	{
		/**
		 * it is hash table, used to store management sloader instance.
		 */		
		private var _sloaders:Object;
		
		/**
		 * it is hash table, save the file to load handler.
		 */		
		private var _fileHandlers:Object;
		
		/**
		 * Paragraphs concept, it is hash table sava all SLoader instance to load the file<SLoaderFile.as>.
		 *
		 *  Loaded file how is added into the group ?
		 *  - when ready to load SLoaderFile, you must set the variable<group> values.
		 *  - when file loaded complete, <SLoaderFile> file variable<group> is the hash table key. it will join the current key - (that is group).
		 *
		 *  We can use getGroupFiles(groupName) method to get the set of data.
		 * 
		 * ==Group Correlation==
		 * variable: _groups(Dictionary)
		 * method: getGroupFiles(groupName:String)
		 * method: addFileToGroup(groupName:String, fileVO:SLoaderFile);
		 */		
		private var _groups:Dictionary;
		
		public function SLoaderManage()
		{
			if (_instance)
				throw new Error("SloaderManage is Singleton Pattern");
			
			_groups = new Dictionary();
			_sloaders = {};
			
			/**set the file type on load handler**/
			_fileHandlers = {};
			_fileHandlers[SLoaderFileType.SWF.toLowerCase()] = SWF_LoadHandler;
			_fileHandlers[SLoaderFileType.XML.toLowerCase()] = XML_LoadHandler;
			_fileHandlers[SLoaderFileType.DAT.toLowerCase()] = Binary_LoadHandler;
			_fileHandlers[SLoaderFileType.JPG.toLowerCase()] = Image_LoadHandler;
			_fileHandlers[SLoaderFileType.PNG.toLowerCase()] = Image_LoadHandler;
			_fileHandlers[SLoaderFileType.BMP.toLowerCase()] = Image_LoadHandler;
			_fileHandlers[SLoaderFileType.CSS.toLowerCase()] = CSS_LoadHandler;
		}
		
		private static var _instance:SLoaderManage;
		public static function get instance():SLoaderManage
		{
			if (!_instance)
				_instance = new SLoaderManage();
			return _instance;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////
		/**
		 * When the instance is created when calling this function added to VARIABLE<_sloaders> management.
		 * @param sloaderName		-- note that the repeated words will cover the instance.
		 * @param sloaderInstance
		 * 
		 */		
		public function addSLoader(sloaderName:String, sloaderInstance:SLoader):void
		{
			_sloaders[sloaderName] = sloaderInstance;
		}
		
		public function removeSLoader(sloaderName:String):void
		{
			delete _sloaders[sloaderName];
		}
		
		public function getSloader(sloaderName:String):SLoader
		{
			return _sloaders[sloaderName];
		}
		
		/**
		 * When you have the <title> of a SLoaderFile file variable, <getFileCorrespondSloader> method can get to load the instance of the file corresponding sloader
		 * @param fileTitle
		 * @return 
		 * 
		 */		
		public function getFileCorrespondSloader(fileTitle:String):SLoader
		{
			for each(var sloader:SLoader in _sloaders)
			{
				var fileVO:SLoaderFile = sloader.getFileVO(fileTitle);
				if (fileVO)
					return sloader;
			}
			return null;
		}
		
		/**
		 * it can be obtained SLoaderFile file.
		 * it will search all SLoaderManage management sloader instance
		 * @param fileTitle
		 * @param sloaderInstance
		 * @return 
		 * 
		 */		
		public function getFileVO(fileTitle:String, sloaderInstance:SLoader=null):SLoaderFile
		{
			if (sloaderInstance)
				return sloaderInstance.getFileVO(fileTitle);
			else
			{
				for each(var sloader:SLoader in _sloaders)
				{
					var fileVO:SLoaderFile = sloader.getFileVO(fileTitle);
					if (fileVO)
						return fileVO;
				}
			}
			return null;
		}
		
		/**
		 * Get SLoaderFile type
		 * SLoaderFile file type variable is set, that uses it return.
		 * SLoaderFile file type variable is not set, to variable<url> to analyze the file type
		 * @param fileVO
		 * @return 
		 * 
		 */		
		public function getFileType(fileVO:SLoaderFile):String
		{
			if (fileVO.type)
				return fileVO.type;
			else
			{
				var urlPath:Array = fileVO.url.split("/");
				var fileName:String = urlPath.length>0 ? urlPath[urlPath.length-1]:fileVO.url;
				fileName = String(fileName.match(/\.[^?]*/));
				fileName = String(fileName.match(/[^\.].*/));
				if (_fileHandlers[fileName])
					return fileName;
			}
			return null;
		}
		
		public function getFileLoadHandler(fileType:String):Class
		{
			return _fileHandlers[fileType];
		}
		
		public function unLoad(fileTitle:String):void
		{
			var fileVO:SLoaderFile = getFileVO(fileTitle);
			if (!fileVO)
				throw new Error("not has the file[title="+fileTitle+"] on all sloader loaded list");
			
			if (fileVO.loaderInfo)
				fileVO.loaderInfo.loadHandler.unLoad();
		}
		
		/**
		 * add files to as group if the group does not exist, then create.
		 * the file can only be added to a group, if the document has been propared to add another group, it will move files to the new group
		 * @param groupName
		 * @param fileVO
		 * 
		 */		
		public function addFileToGroup(groupName:String, fileVO:SLoaderFile):void
		{
			if (groupName == fileVO.group)
				return;
			
			if (!_groups[fileVO.group])
				return;
			
			var index:int;
			index = _groups[fileVO.group].indexOf(fileVO);
			if (index != -1)
				_groups[fileVO.group].splice(index, 1);
			else
			{
				for each(var group:Array in _groups)
				{
					index = group.indexOf(fileVO);
					if (index != -1){
						group.splice(index, 1);
						break;
					}
				}
			}
				
			_groups[groupName].push(fileVO);
		}
		
		public function getGroupFiles(groupName:String):Array
		{
			var groupFiles:Array = [];
			groupFiles.concat(_groups[groupName]);
			return groupFiles;
		}
	}
}