package com.sloader.define
{
	import com.sloader.handlers.SLoaderHandler;
	
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	public class SLoaderFileInfo
	{
		public var loadedBytes:int;
		
		public var totalBytes:int;
		
		public var loaderHandler:SLoaderHandler;
	}
}