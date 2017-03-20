// Debug=on
// Character Encoding: "WHITE SQUARE" U+25A1 is □.
using  col = System.Collections.Generic;  // Alias "col::"
using  co = CS_Lib;  // Alias "co::"
using  d = System.Diagnostics;  // Alias "d::"
using  g_f = CS_Lib.Function;  // Alias "g_f."
using  g_e = System.Environment;  // Alias "g_e."
using  g_t = System.Diagnostics.Trace;  // Alias "g_t."
using  io = System.IO;  // Alias "io::"
using  s = System;  // Alias "s::"
using  tx = System.Text;  // Alias "tx::"


class MainClass
{
	static void  Main()
	{
//		MainClass.UpdateFolderMD5List(
//			g_e.ExpandEnvironmentVariables(
//				@"%myhome_mem%\MyDoc\src\cs_script\UpdateMD5List\Test\Files" ),
//			g_e.ExpandEnvironmentVariables(
//				@"%myhome_mem%\MyDoc\src\cs_script\UpdateMD5List\Test\MD5List.txt" ),
//			g_e.ExpandEnvironmentVariables(
//				@"%myhome_mem%\MyDoc\src\cs_script\UpdateMD5List\Test\MD5List_out.txt" ) );
		MainClass.UpdateFolderMD5List(
			g_e.GetCommandLineArgs()[1],
			g_e.GetCommandLineArgs()[2],
			g_e.GetCommandLineArgs()[3] );
	}


	static void  UpdateFolderMD5List( string  in_TargetFolderPath,
		string  in_InputMD5ListFilePath,  string  in_OutputMD5ListFilePath )
	{
	using ( var  disposer = new co::Disposer() ) {

		var  file_r = new io::StreamReader( in_InputMD5ListFilePath );  disposer.Add( file_r );
		var  line = "";
		var  length_of_W3CDTF = 25;
		var  column_of_path = 59;
		var  hash_list = new col::Dictionary<string,string>();
		var  target_folder_full_path = (string) g_f.GetFullPath( in_TargetFolderPath,  null );
		var  hash_value_of_empty_folder = "00000000000000000000000000000000";
		var  time_stamp_W3CDTF_of_empty_folder = "2001-01-01T00:00:00+00:00";

		while ( (line = file_r.ReadLine()) != null ) {
			g_t.Assert( line[4] == '-' );  // Next of year in W3CDTF

			var  path = line.Substring( column_of_path );
			hash_list[ path ] = line;
		}
		file_r.Dispose();  disposer.Remove( file_r );
		g_f.MakeFolderFor( in_OutputMD5ListFilePath );


		var file_w = new io::StreamWriter(
				in_OutputMD5ListFilePath,  false,  tx::Encoding.Unicode );
			disposer.Add( file_w );

		var  files_and_folders = (col::IEnumerable<io::FileSystemInfo>) new io::DirectoryInfo(
			in_TargetFolderPath
			).EnumerateFileSystemInfos( "*",  io::SearchOption.AllDirectories );

		foreach ( io::FileSystemInfo  file_or_folder  in  files_and_folders ) {
		using ( var  disposer2 = new co::Disposer() ) {
			line = null;

			var file = file_or_folder  as  io::FileInfo;
			if ( file != null ) {
				var  path = file.FullName;
				var  relative_path = co::Function.GetRelativePath( path,  target_folder_full_path );
				var  time_stamp_W3CDTF = (string) file.LastWriteTime.ToString("yyyy-MM-ddTHH:mm:ssK");

				if ( hash_list.ContainsKey( relative_path ) ) {

					line = hash_list[ relative_path ];
					var  time_stamp_W3CDTF_in_list = line.Substring( 0,  length_of_W3CDTF );
					if ( time_stamp_W3CDTF != time_stamp_W3CDTF_in_list ) {
						line = null;
					}
				}

				if ( line == null ) {
					var  file_stream = new io::FileStream(
						path,  io::FileMode.Open, io::FileAccess.Read, io::FileShare.Read );
						disposer2.Add( file_stream );
					var  hash_computer = new s::Security.Cryptography.MD5CryptoServiceProvider();
						disposer2.Add( hash_computer );
					var  hash_bytes = (byte[]) hash_computer.ComputeHash(
						file_stream );
					var  hash_value = s::BitConverter.ToString(
						hash_bytes ).ToLower().Replace("-","");

					line = time_stamp_W3CDTF +" "+ hash_value +" "+ relative_path;

					hash_list[ path ] = line;
				}
			}

			var folder = file_or_folder  as  io::DirectoryInfo;
			if ( folder != null ) {
				var  count = (int) 0;
				foreach ( io::FileSystemInfo  info  in  folder.EnumerateFileSystemInfos() ) {
					count += 1;
				}
				if ( count == 0 ) {  /* Empty folder */
					var  path = folder.FullName;
					var  relative_path = co::Function.GetRelativePath( path,  target_folder_full_path );

					line = time_stamp_W3CDTF_of_empty_folder +" "+ hash_value_of_empty_folder +" "+
						relative_path;
				}
			}

			if ( line != null ) {
				file_w.WriteLine( line );
			}
		}
		}
	}
	}
}

namespace  CS_Lib
{
	/***********************************************************************
	* Class: Disposer
	************************************************************************/
	public class Disposer : col::List<System.IDisposable>, System.IDisposable
	{
		public void  Dispose()
		{
			foreach ( System.IDisposable  item  in  this ) {
				item.Dispose();
			}
			this.Clear();
		}

		~Disposer()
		{
			this.Dispose();
		}
	}


	/***********************************************************************
	* Class: Function
	************************************************************************/
	public class  Function
	{
		/***********************************************************************
		* Function: CutLastOf
		************************************************************************/
		public static string  CutLastOf( string  in_InputString,  string  in_LastString )
		{
			if ( in_InputString.Substring( in_InputString.Length - in_LastString.Length ) == in_LastString ) {
				return  in_InputString.Substring( 0,  in_InputString.Length - in_LastString.Length );
			} else {
				return  in_InputString;
			}
		}


		/***********************************************************************
		* Function: GetFilePathSeparator
		************************************************************************/
		public static char  GetFilePathSeparator( string  in_Path )
		{
			char  separator;

			var  index = (int)  in_Path.IndexOfAny( new char[] { '/', '\\' } );

			if ( index == -1 ) {
				separator = '\\';
			} else {
				separator = in_Path[ index ];
			}

			return  separator;
		}


		/***********************************************************************
		* Function: GetFullPath
		************************************************************************/
		public static string  GetFullPath( string  in_Path,  string  in_BasePath )
		{
			string  full_path;

			if ( in_BasePath == null ) {
				full_path = in_Path;
			} else {
				d::Trace.Assert( io::Path.IsPathRooted( in_BasePath ) );
				full_path = io::Path.Combine( in_BasePath,  in_Path );
			}

			full_path = io::Path.GetFullPath( full_path );  // Normalize

			return  full_path;
		}


		/***********************************************************************
		* Function: GetRelativePath
		************************************************************************/
		public static string  GetRelativePath( string  in_Path,  string  in_BasePath )
		{
			var  relative_path = (string) null;

			if ( ! io::Path.IsPathRooted( in_Path ) ) {
				relative_path = in_Path;
			} else {
				g_t.Assert( io::Path.IsPathRooted( in_BasePath ) );

				var  path_1_ = (string) io::Path.GetFullPath( in_Path );  // Normalize
				var  path_0_ = (string) io::Path.GetFullPath( in_BasePath );  // Normalize
				var  path_1 = (string) path_1_.Replace( "/", @"\" );
				var  path_0 = (string) path_0_.Replace( "/", @"\" );
				var  previous_index_1 = (int) 0;
				var  previous_index_0 = (int) 0;
				for /*ever*/ (;;) {
					var  name_1 = (string) null;
					var  name_0 = (string) null;
					var  index_1 = (int) path_1.IndexOf( @"\",  previous_index_1 );
					var  index_0 = (int) path_0.IndexOf( @"\",  previous_index_0 );
					if ( index_1 == -1 ) {
						name_1 = path_1.Substring( previous_index_1 );
					} else {
						name_1 = path_1.Substring( previous_index_1,  index_1 - previous_index_1 );
					}
					if ( index_0 == -1 ) {
						name_0 = path_0.Substring( previous_index_0 );
					} else {
						name_0 = path_0.Substring( previous_index_0,  index_0 - previous_index_0 );
					}

					if ( index_0 == -1 ) {
						if ( index_1 == -1 ) {  // 1-path, 0-base
							if ( string.Compare( name_1,  name_0,  true ) == 0 ) {
								relative_path = ".";
							} else {
								relative_path = @"..\"+ name_1;
							}
						} else {  // 1-path\sub, 0-base
							if ( string.Compare( name_1,  name_0,  true ) == 0 ) {
								relative_path = path_1.Substring( index_1 + 1 );
							} else {
								relative_path = @"..\"+ path_1.Substring( previous_index_1 );
							}
						}
						break;
					}
					else {
						if ( index_1 == -1 ) {  // 1-path, 0-base\sub
							if ( string.Compare( name_1,  name_0,  true ) == 0 ) {
								relative_path = @"..\";
							} else {
								relative_path = @"..\..\"+ name_1;
							}
						} else {  // 1-path\sub, 0-base\sub
							if ( string.Compare( name_1,  name_0,  true ) == 0 ) {
								relative_path = null;
							} else {
								if ( previous_index_1 == 0 ) {
									relative_path = in_Path;
									break;
								} else {
									relative_path = @"..\..\"+ name_1;
								}
							}
						}
						if ( relative_path != null ) {
							for /*ever*/ (;;) {
								previous_index_0 = index_0 + 1;
								index_0 = path_0.IndexOf( @"\",  previous_index_0 );
								if ( index_0 == -1 )
									{ break; }
								relative_path += @"..\";
							}
							relative_path = relative_path.Substring( 0,  relative_path.Length - 1 );
							break;
						}
					}
					previous_index_1 = index_1 + 1;
					previous_index_0 = index_0 + 1;
				}

				if ( co::Function.GetFilePathSeparator( in_Path ) == '/' ) {
					relative_path = relative_path.Replace( @"\", "/" );
				}
			}

			return  relative_path;
		}


		/***********************************************************************
		* Function: MakeFolderFor
		************************************************************************/
		public static void  MakeFolderFor( string  in_Path )
		{
			var  parent_path = (string) io::Path.GetDirectoryName( in_Path );

			if ( ! io::Directory.Exists( parent_path ) ) {
				io::Directory.CreateDirectory( parent_path );
			}
		}


		/***********************************************************************
		* Function: Print
		*    Visual Studio の [ 表示 >> 出力 ] に表示します。
		************************************************************************/
		public static void  Print( string  in_Message )
		{
			var  frame = new d::StackFrame( 1, true );
			var  line_num = (int) frame.GetFileLineNumber();

			d::Trace.WriteLine( line_num.ToString() +": "+ in_Message );
				// *.exe ファイルの隣に *.pdb ファイルが無いと、0行と表示されます。
		}
	}
}


