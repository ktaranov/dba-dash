﻿using Octokit;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace DBADash
{
    public class Upgrade
    {

        public const string GITHUB_OWNER = "trimble-oss"; 
        public const string GITHUB_REPO = "dba-dash";
        public const string GITHUB_APP = "dba-dash";
        public const string GITHUB_BRANCH = "main";
        public const string GITHUB_UPGRADESCRIPT = "UpgradeDBADash.ps1";
        public const string GITHUB_SCRIPTPATH = "Scripts/";

        public const string AppURL = "http://dbadash.com";
        public const string AuthorURL = "https://github.com/DavidWiseman";
        public const string ServiceFileName = "DBADashService.exe";

        public enum DeploymentTypes
        {
            GUI,
            ServiceAndGUI
        }

        /// <summary>Get latest release from github</summary> 
        public static async Task<Release> GetLatestVersionAsync()
        {
            var client = new GitHubClient(new ProductHeaderValue(GITHUB_APP));
            return await client.Repository.Release.GetLatest(GITHUB_OWNER, GITHUB_REPO);
        }

        public static bool IsUpgradeAvailable(Release release)
        {
            var releaseVersion = new Version(release.TagName);
            return (CurrentVersion().CompareTo(releaseVersion) < 0);
        }

        public static Version CurrentVersion()
        {
            return Assembly.GetExecutingAssembly().GetName().Version;
        }


        public static async Task UpgradeDBADashAsync(string tag = "",bool startGUI=false, bool startConfig=false)
        {
            var client = new GitHubClient(new ProductHeaderValue(GITHUB_APP));
            var upgradeScript = await client.Repository.Content.GetRawContentByRef(GITHUB_OWNER,GITHUB_REPO, GITHUB_SCRIPTPATH + GITHUB_UPGRADESCRIPT, GITHUB_BRANCH);

            System.IO.File.WriteAllBytes(GITHUB_UPGRADESCRIPT, upgradeScript);
            // Note: Setting working directory via ProcessStartInfo doesn't work when using "runas" verb. 
            var psi = new ProcessStartInfo()
            {
                FileName = "PowerShell.exe",
                Arguments = "-NoProfile -NoExit -ExecutionPolicy ByPass -Command &{" +
                               $"Set-Location -Path '{ApplicationPath}'; " +
                               $"./{GITHUB_UPGRADESCRIPT}" +
                                            (tag == String.Empty ? string.Empty : " -Tag " + tag)
                                            + (startGUI ? " -StartGUI" : string.Empty)
                                            + (startConfig ? " -StartConfig" : string.Empty
                                            + $" -Repo \"{GITHUB_OWNER}/{GITHUB_REPO}\"")
                                            + "}",
                UseShellExecute = true,
                Verb = "runas"
            };

            Process.Start(psi);
        }

        public static string ApplicationPath
        {
            get
            {
               return Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            }
        }

        public static DeploymentTypes DeploymentType
        {
            get
            {
                if (File.Exists(Path.Combine(ApplicationPath,ServiceFileName)))
                {
                    return DeploymentTypes.ServiceAndGUI;
                }
                else
                {
                    return DeploymentTypes.GUI;
                }
            }
        }

        public static string LatestVersionLink
        {
            get
            {
                return $"https://github.com/{Upgrade.GITHUB_OWNER}/{Upgrade.GITHUB_REPO}/releases/latest";
            }
        }
    }
}
