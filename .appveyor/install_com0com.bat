Setlocal EnableDelayedExpansion EnableExtensions
set COM0COM_ROOT=c:\com0com
set COM0COM_BASE=com0com-3.0.0.0-i386-and-x64
set COM0COM_URL=http://downloads.sourceforge.net/project/com0com/com0com/3.0.0.0/%COM0COM_BASE%-unsigned.zip

if not exist %COM0COM_ROOT%\setupc.exe (
  echo ======================================================
  echo Download com0com
  echo ======================================================
  curl --output tt.zip --silent --fail --max-time 120 --connect-timeout 30 -L %COM0COM_URL%
  7z x -aoa tt.zip
  rm tt.zip
  cd %COM0COM_BASE% && .\setup.exe /S %COM0COM_ROOT%
  cd %COM0COM_ROOT%
  echo ======================================================
  echo install virtual serial ports
  echo ======================================================
  ./setupc --silent --detail-prms install 0 - -
  ./setupc --silent --detail-prms install 1 - -
)
