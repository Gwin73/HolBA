signature bir_scamv_driverLib = sig

  val scamv_test_main : unit -> unit

  val scamv_test_mock : unit -> bool

  val scamv_test_asmf : string -> bool

end
