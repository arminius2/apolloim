/*

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; version 2
 of the License.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#import "MainView.h"
#import "CoreAudio.h"


int __screenOrientation;

extern unsigned long dwKeySystem;
extern char emuThread;
extern AudioDeviceID defaultOutputDevice, basebandDevice;
int audioIsSpeaker;

@implementation MainView 
- (id)initWithFrame:(struct CGRect)rect {
	}

- (void)dealloc {

}

- (void)alertSheet:(UIAlertSheet *)sheet buttonClicked:(int)button {

}

- (void)navigationBar:(UINavigationBar *)navbar buttonClicked:(int)button {
}

- (void)fileBrowser: (FileBrowser *)browser fileSelected:(NSString *)file {
}

- (void)deviceOrientationChanged {
 
}

- (void)startEmulator {
}

- (void)stopEmulator {
    }

- (int)isBrowsing {

}

@end
