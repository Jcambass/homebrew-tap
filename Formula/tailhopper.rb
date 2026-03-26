class Tailhopper < Formula
  desc "Use multiple Tailscale tailnets at the same time"
  homepage "https://github.com/jcambass/tailhopper"
  url "https://github.com/Jcambass/tailhopper/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "4ca551ab69c7f118710b167b2e2479e14ca4b708ec18f90fb9d7095fe38fcfb6"
  license "MIT"
  head "https://github.com/jcambass/tailhopper.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=#{version}"), "./cmd/tailhopper"
    (var/"tailhopper").mkpath
  end

  service do
    run [opt_bin/"tailhopper"]
    environment_variables HTTP_PORT: ENV.fetch("TAILHOPPER_HTTP_PORT", "8888")
    keep_alive true
    working_dir var/"tailhopper"
    log_path var/"log/tailhopper.log"
    error_log_path var/"log/tailhopper.log"
  end

  def caveats
    <<~EOS
      Once Tailhopper is running, you can access:
      - The dashboard at http://localhost:#{ENV.fetch("TAILHOPPER_HTTP_PORT", "8888")}
      - The logs at #{var}/log/tailhopper.log
      - The state file and state folder at #{var}/tailhopper

      To use a custom HTTP port, set the TAILHOPPER_HTTP_PORT environment variable before starting the service:
        export TAILHOPPER_HTTP_PORT=8080

      To stop Tailhopper:
        brew services stop tailhopper

      To uninstall Tailhopper while keeping state/log files:
        brew services stop tailhopper
        brew uninstall tailhopper

      To uninstall Tailhopper while also removing state/log files:
        brew services stop tailhopper
        brew uninstall tailhopper
        rm -rf "$(brew --prefix)/var/tailhopper" "$(brew --prefix)/var/log/tailhopper.log"
    EOS
  end

  test do
    assert_equal "#{version}\n", shell_output("#{bin}/tailhopper --version")
  end
end
