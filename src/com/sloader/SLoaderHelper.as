package com.sloader
{
	import com.sloader.define.SLoaderFile;

	public class SLoaderHelper
	{
		public static function getFileType(sloaderFile:SLoaderFile):String
		{
			if (sloaderFile.type)
				return sloaderFile.type;
			
			var urlPath:Array = sloaderFile.url.split("/");
			var fileType:String = urlPath.length>0 ? urlPath[urlPath.length-1]:sloaderFile.url;
			fileType = String(fileType.match(/\.[^?]*/));
			fileType = String(fileType.match(/[^\.].*/));
			return fileType;
		}
	}
}