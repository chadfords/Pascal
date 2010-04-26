{
  ESS-Model
  Copyright (C) 2002  Eldean AB, Peter S�derman, Ville Krumlinde

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
}

{
  Definition of TModelEntity is in it's own unit to avoid a circular unit
  reference bwtween uModel and uListeners

  TBaseModelIterator is defined here for the same reason.
}
unit uModelEntity;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  LCLIntf, LCLType, LMessages, Sysutils, Classes, contnrs,
  uDocumentation;

type
  TListenerMethodType = (mtBeforeChange, mtBeforeAddChild, mtBeforeRemove, mtBeforeEntityChange,
    mtAfterChange, mtAfterAddChild, mtAfterRemove, mtAfterEntityChange);

  TVisibility = (viPrivate, viProtected, viPublic, viPublished);

  { TModelEntity }

  TModelEntity = class(TObject)
  private
    function GetRoot: TModelEntity;
  protected
    FName: string;
    FOwner: TModelEntity;
    FDocumentation : TDocumentation;
    FVisibility: TVisibility;
    FListeners: TList; // TInterfaceList;
//    FListenerTypes: TListenerTypes;
    FLocked: boolean;
    procedure SetName(const Value: string); virtual;
    function GetFullName: string;
//    class function GetBeforeListener: TGUID; virtual;
//    class function GetAfterListener: TGUID; virtual;
    procedure SetVisibility(const Value: TVisibility);
    function GetLocked: boolean;
    procedure Fire(Method: TListenerMethodType; Info: TModelEntity = nil); virtual;
    {IUnknown, beh�vs f�r att kunna vara lyssnare}
{    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;  }
  public
    constructor Create(Owner: TModelEntity); virtual;
    destructor Destroy; override;
    procedure AddListener(NewListener: TObject);
    procedure RemoveListener(Listener: TObject);
    // Dispatch functions, earlier interfaces took care of them.
    procedure BeforeAddChild(Sender: TModelEntity; NewChild: TModelEntity); virtual;
    procedure BeforeRemove(Sender: TModelEntity); virtual;
    procedure BeforeChange(Sender: TModelEntity); virtual;
    procedure BeforeEntityChange(Sender: TModelEntity); virtual;
    procedure AfterAddChild(Sender: TModelEntity; NewChild: TModelEntity); virtual;
    procedure AfterRemove(Sender: TModelEntity); virtual;
    procedure AfterChange(Sender: TModelEntity); virtual;
    procedure AfterEntityChange(Sender: TModelEntity); virtual;
  public
    property Name: string read FName write SetName;
    property FullName: string read GetFullName;
    property Owner: TModelEntity read FOwner write FOwner;
    property Visibility: TVisibility read FVisibility write SetVisibility;
    property Locked: boolean read GetLocked write FLocked;
    property Root : TModelEntity read GetRoot;
    property Documentation : TDocumentation read FDocumentation;
  end;

  TModelEntityClass = class of TModelEntity;

  //Sortorder for iterators
  TIteratorOrder = (ioNone,ioVisibility,ioAlpha{,ioType});

  // Interfaces replaced with abstract base class.

  TBaseModelIterator = class abstract
    function HasNext : boolean; virtual; abstract;
    function Next : TModelEntity; virtual; abstract;
    procedure Reset; virtual; abstract;
    function Count : integer; virtual; abstract;
  end;

  TBaseIteratorFilter = class abstract
    function Accept(M : TModelEntity) : boolean; virtual; abstract;
  end;

  //Basinterface for iterators
//  I*ModelIterator = interface(IUnknown)
//    ['{42329900-029F-46AE-96ED-6D4ABBEAFD4F}']
{    function HasNext : boolean;
    function Next : TModelEntity;
    procedure Reset;
    function Count : integer;
  end;
}
  //Basinterface for iteratorfilters
//  I*IteratorFilter = interface(IUnknown)
//    ['{FD77FD42-456C-4B8A-A917-A2555881E164}']
//    function Accept(M : TModelEntity) : boolean;
//  end;

implementation

uses uListeners;

{ TModelEntity }

constructor TModelEntity.Create(Owner: TModelEntity);
begin
  inherited Create;
  Self.Owner := Owner;
  FListeners := TList.Create;
  FDocumentation := TDocumentation.Create;
end;

destructor TModelEntity.Destroy;
begin
  FreeAndNil(FDocumentation);
  FreeAndNil(FListeners);
  inherited;
end;

function TModelEntity.GetFullName: string;
begin
  if Assigned(FOwner) then
    Result := FOwner.FullName + '::' + FName
  else
    Result := FName;
end;

function TModelEntity.GetLocked: boolean;
begin
//Sant ifall detta object eller n�got ovanf�r i ownerhierarkien �r l�st
  Result := FLocked or (Assigned(Owner) and Owner.Locked);
end;

procedure TModelEntity.AddListener(NewListener: TObject);
begin
  if FListeners.IndexOf(NewListener) = -1 then
    FListeners.Add(NewListener);
end;

procedure TModelEntity.RemoveListener(Listener: TObject);
begin
  FListeners.Remove(Listener);
end;


//
procedure TModelEntity.BeforeAddChild(Sender: TModelEntity; NewChild: TModelEntity);
begin
  ;
end;

procedure TModelEntity.BeforeRemove(Sender: TModelEntity);
begin
  ;
end;

procedure TModelEntity.BeforeChange(Sender: TModelEntity);
begin
  ;
end;

procedure TModelEntity.BeforeEntityChange(Sender: TModelEntity);
begin
  ;
end;

procedure TModelEntity.AfterAddChild(Sender: TModelEntity; NewChild: TModelEntity);
begin
  ;
end;

procedure TModelEntity.AfterRemove(Sender: TModelEntity);
begin
  ;
end;

procedure TModelEntity.AfterChange(Sender: TModelEntity);
begin
  ;
end;

procedure TModelEntity.AfterEntityChange(Sender: TModelEntity);
begin
  ;
end;

//
procedure TModelEntity.SetName(const Value: string);
var
  OldName: string;
begin
  OldName := FName;
  FName := Value;
  try
    Fire(mtBeforeEntityChange)
  except
    FName := OldName;
    raise;
  end {try};
  Fire(mtAfterEntityChange)
end;

procedure TModelEntity.SetVisibility(const Value: TVisibility);
var
  Old: TVisibility;
begin
  Old := Value;
  FVisibility := Value;
  try
    Fire(mtBeforeEntityChange)
  except
    FVisibility := Old;
    raise;
  end {try};
  Fire(mtAfterEntityChange)
end;

procedure TModelEntity.Fire(Method: TListenerMethodType; Info: TModelEntity = nil);
var
  I: integer;
//  IL: IModelEntityListener;
  L: TObject;
  s: String;
begin
  if not Locked then
    for I := 0 to FListeners.Count - 1 do
    begin
      L := FListeners[I];
      if L is TModelEntity then begin
        case Method of
          mtBeforeAddChild:      // if Supports(L, GetBeforeListener, IL) then
            (L as TModelEntity).BeforeAddChild(Self, Info);
          mtBeforeRemove:        // if Supports(L, GetBeforeListener, IL) then
            (L as TModelEntity).BeforeRemove(Self);
          mtBeforeChange:        // if Supports(L, GetBeforeListener, IL) then
            (L as TModelEntity).BeforeChange(Self);
          mtBeforeEntityChange:  // if Supports(L, GetBeforeListener, IL) then
            (L as TModelEntity).BeforeEntityChange(Self);
          mtAfterAddChild:       // if Supports(L, GetAfterListener, IL) then
            (L as TModelEntity).AfterAddChild(Self, Info);
          mtAfterRemove:         // if Supports(L, GetAfterListener, IL) then
            (L as TModelEntity).AfterRemove(Self);
          mtAfterChange:         // if Supports(L, GetAfterListener, IL) then
            (L as TModelEntity).AfterChange(Self);
          mtAfterEntityChange:   // if Supports(L, GetAfterListener, IL) then
            (L as TModelEntity).AfterEntityChange(Self);
        else
          raise Exception.Create(ClassName + ' Eventmethod not recognized.');
        end {case};
      end
      else begin //if L is TControl then
        s:=L.ClassName;
        raise Exception.Create(
                  Format('TObjectModel.Fire should support type "%s".', [s]));
      end;
    end;
end;

{
function TModelEntity.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then Result := S_OK
  else Result := E_NOINTERFACE
end;

function TModelEntity._AddRef: Integer;
begin
  Result := -1; // -1 indicates no reference counting is taking place
end;

function TModelEntity._Release: Integer;
begin
  Result := -1; // -1 indicates no reference counting is taking place
end;

class function TModelEntity.GetAfterListener: TGUID;
begin
  raise Exception.Create( ClassName + '.GetAfterListener');
end;

class function TModelEntity.GetBeforeListener: TGUID;
begin
  raise Exception.Create( ClassName + '.GetBeforeListener');
end;
}
function TModelEntity.GetRoot: TModelEntity;
begin
  Result := Self;
  while Result.Owner<>nil do
    Result := Result.Owner;
end;

end.