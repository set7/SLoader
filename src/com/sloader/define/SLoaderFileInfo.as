package com.sloader.define
{
	import com.sloader.handlers.SLoadHandler;
	
	import flash.system.ApplicationDomain;

	public class SLoaderFileInfo
	{
		public var loadedBytes:int;
		
		public var totalBytes:int;
		
		public var loadHandler:SLoadHandler;
	}
}