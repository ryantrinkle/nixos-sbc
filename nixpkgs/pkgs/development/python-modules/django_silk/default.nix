{ stdenv
, buildPythonPackage
, python
, fetchFromGitHub
, django
, pygments
, simplejson
, dateutil
, requests
, sqlparse
, jinja2
, autopep8
, pytz
, pillow
, mock
, gprof2dot
, freezegun
, contextlib2
, networkx
, pydot
, factory_boy
}:

buildPythonPackage rec {
  pname = "django-silk";
  version = "3.0.3";

  # pypi tarball doesn't include test project
  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-silk";
    rev = version;
    sha256 = "0j1r88zv7fvmlnrzr2h65czzdcpvl7n847ra1pfc52bfa4lf8b9j";
  };
  # "test_time_taken" tests aren't suitable for reproducible execution, but django's
  # test runner doesn't have an easy way to ignore tests - so instead prevent it from picking
  # them up as tests
  postPatch = ''
    substituteInPlace project/tests/test_silky_profiler.py \
      --replace "def test_time_taken" "def _test_time_taken"
  '';

  buildInputs = [ mock ];
  propagatedBuildInputs = [
    django pygments simplejson dateutil requests
    sqlparse jinja2 autopep8 pytz pillow gprof2dot
  ];

  checkInputs = [ freezegun contextlib2 networkx pydot factory_boy ];
  checkPhase = ''
    cd project
    DB=sqlite3 DB_NAME=db.sqlite3 ${python.interpreter} manage.py test
  '';

  meta = with stdenv.lib; {
    description = "Silky smooth profiling for the Django Framework";
    homepage = https://github.com/mtford90/silk;
    license = licenses.mit;
    maintainers = with maintainers; [ ris ];
  };

}
