Setlocal EnableDelayedExpansion EnableExtensions

set COM0COM_ROOT=c:\com0com
set COM0COM_BASE=com0com-3.0.0.0-i386-and-x64
set COM0COM_URL=http://downloads.sourceforge.net/project/com0com/com0com/3.0.0.0/%COM0COM_BASE%-unsigned.zip

if not exist %COM0COM_ROOT%\setupc.exe (
  mkdir %COM0COM_ROOT%
  echo ======================================================
  echo Download com0com
  echo ======================================================
  curl --silent --fail --max-time 120 --connect-timeout 30 -L --output %COM0COM_ROOT%\com0com.cer https://github.com/hybridgroup/rubyserial/raw/appveyor_deps/com0com.cer
  curl --silent --fail --max-time 120 --connect-timeout 30 -L --output setup_com0com_W7_x64_signed.exe https://github.com/hybridgroup/rubyserial/raw/appveyor_deps/setup_com0com_W7_x64_signed.exe
)

echo ======================================================
echo install certificate
echo ======================================================
CertMgr /add %COM0COM_ROOT%/com0com.cer /s /r localMachine root
CertMgr /add %COM0COM_ROOT%/com0com.cer /s /r localMachine trustedpublisher

if not exist %COM0COM_ROOT%\setupc.exe (
  echo ======================================================
  echo Install com0com
  echo ======================================================
  setup_com0com_W7_x64_signed.exe /S /D=%COM0COM_ROOT%
  dir %COM0COM_ROOT%
)

echo ======================================================
echo install virtual serial ports
echo ======================================================
cd %COM0COM_ROOT%
.\setupc.exe --silent --detail-prms install 0 - -
.\setupc.exe --silent --detail-prms install 1 - -
